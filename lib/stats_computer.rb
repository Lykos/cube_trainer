require 'cube_average'
require 'buffer_helper'
require 'results_persistence'
require 'math_helper'

module CubeTrainer

  class StatsComputer

    include MathHelper

    PROBABILITIES_KEY_MAP = {
      corner_commutators: :corner_targets,
      corner_3twists: :twists,
      floating_2twists: :twists,
      edge_commutators: :edge_targets_no_parity,
      floating_2flips: :flips,
    }

    EXPECTED_ALG_LAMBDAS = {
      corner_commutators: lambda { |t, p| t / 2 * p },  # The parity alg is not a corner comm.
      corner_3twists: lambda { |t, p| (t / 2) * 0.5 * p },  # We only need one alg for 2 targets and only half of the times it's a 3 twist.
      floating_2twists: lambda { |t, p| ((t + 1) / 2) * 0.5 * p },  # We only need one alg for 2 targets and only half of the times it's a 2 flip.
      edge_commutators: lambda { |t, p| (t / 2) * p },  # We need one alg for 2 targets
      floating_2flips: lambda { |t, p| ((t + 1) / 2) * 0.5 * p },  # We only need one alg for 2 targets.
    }

    def probabilities
      @probabilities ||= YAML::load_file('data/probabilities.yml')
    end
    
    def initialize(options, results_persistence=ResultsPersistence.create_for_production)
      @options = options
      mode = BufferHelper.mode_for_buffer(options)
      results = results_persistence.load_results(mode)
      @grouped_results = results.group_by { |c| c.input }
      grouped_averages = @grouped_results.collect { |c, rs| [c, average_time(rs)] }
      @averages = grouped_averages.sort_by { |t| -t[1] }

      now = Time.now

      old_grouped_results = results.select { |r| r.timestamp < now - 24 * 3600 }.group_by { |c| c.input }
      old_grouped_averages = old_grouped_results.collect { |c, rs| [c, average_time(rs)] }
      @old_averages = old_grouped_averages.sort_by { |t| -t[1] }

      @num_results = results.length
      @num_recent_results = results.count { |r| r.timestamp > now - 24 * 3600 }

      result_symbol = options.commutator_info.result_symbol
      probabilities_key = PROBABILITIES_KEY_MAP[result_symbol]
      if probabilities_key
        relevant_probabilities = probabilities[probabilities_key]
        probabilities_sum = relevant_probabilities.values.reduce(:+)
        raise if (probabilities_sum - 1.0).abs > 0.001
        transformer = EXPECTED_ALG_LAMBDAS[result_symbol]
        @expected_targets = relevant_probabilities.collect(&transformer).reduce(:+)
      end
    end

    attr_reader :averages, :old_averages, :expected_targets, :num_results, :num_recent_results

    def input_stats(inputs)
      hashes = inputs.collect { |e| e.hash }
      filtered_results = @grouped_results.select { |input, rs| hashes.include?(input.hash) }
      newish_elements = filtered_results.collect { |input, rs| rs.length }.count { |l| 1 <= l && l < @options.new_item_boundary }
      found = filtered_results.keys.uniq.length
      total = inputs.length
      missing = total - found
      {
        found: found,
        total: total,
        newish_elements: newish_elements,
        missing: missing
      }
    end

    # Interesting time boundaries to see the number of bad results above that boundary. It allows to display things like "9 results are above 4.5 and one result is above 5"
    def cutoffs
      return [] if @averages.length < 20
      # TODO: Take mode and target into account
      some_bad_result = @averages[9][1]
      step = floor_to_nice(some_bad_result / 10)
      start = floor_to_step(some_bad_result, step)
      finish = start + step * 5
      start.step(finish, step).to_a
    end

    def bad_results
      @bad_results ||= begin
                       cutoffs.collect do |cutoff|
                         [cutoff, @averages.count { |v| v[1] > cutoff }]
                       end
                     end
    end

    def total_average
      @total_average ||= @averages.collect { |c, t| t }.reduce(:+) / @averages.length
    end
      
    def old_total_average
      @old_total_average ||= @old_averages.collect { |c, t| t }.reduce(:+) / @old_averages.length
    end
      
    def average_time(results)
      average(float_times_s(results))
    end
  
    def average(values)
      avg = CubeAverage.new(5, 0)
      values.each { |v| avg.push(v) }
      avg.average
    end
  
    def float_times_s(results)
      results.collect { |result| result.time_s }
    end
    
  end

end
