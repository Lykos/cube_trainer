# frozen_string_literal: true

require 'cube_trainer/buffer_helper'
require 'cube_trainer/native'
require 'cube_trainer/probabilities'
require 'cube_trainer/results_persistence'
require 'cube_trainer/utils/math_helper'

module CubeTrainer
  # Helper class to compute all kinds of cubing stats
  class StatsComputer
    include Utils::MathHelper

    RECENCY_THRESHOLD_SECONDS = 24 * 60 * 60

    def initialize(now, options, results_persistence = ResultsPersistence.create_for_production)
      raise TypeError unless now.is_a?(Time)
      raise TypeError unless results_persistence.respond_to?(:load_results)

      @now = now
      @options = options
      @results_persistence = results_persistence
    end

    def results_for_inputs(inputs)
      hashes = inputs.collect { |e| e.representation.hash }
      filtered_results = grouped_results.select { |input, _rs| hashes.include?(input.hash) }
    end

    def newish_elements(filtered_results)
      lengths = filtered_results.collect { |_input, rs| rs.length }
      newish_elements = lengths.count { |l| l >= 1 && l < @options.new_item_boundary }
    end

    def input_stats(inputs)
      filtered_results = results_for_inputs(inputs)
      found = filtered_results.keys.uniq.length
      total = inputs.length
      missing = total - found
      {
        found: found,
        total: total,
        newish_elements: newish_elements(filtered_results),
        missing: missing
      }
    end

    def expected_time_per_type_stats
      @expected_time_per_type_stats ||= begin
                                          computer = ExpectedTimeComputer.new(@now,
                                                                              @options,
                                                                              @results_persistence)
                                          computer.compute_expected_time_per_type_stats
                                        end
    end

    def bad_results
      @bad_results ||= begin
                       cutoffs.collect do |cutoff|
                         [cutoff, @averages.count { |v| v[1] > cutoff }]
                       end
                     end
    end

    def compute_total_average(averages)
      if averages.empty?
        Float::INFINITY
      else
        averages.collect { |_c, t| t }.reduce(:+) / averages.length
      end
    end

    def total_average
      @total_average ||= compute_total_average(averages)
    end

    def old_total_average
      @old_total_average ||= compute_total_average(old_averages)
    end

    def average_time(results)
      avg = Native::CubeAverage.new(5, 0)
      results.sort_by(&:timestamp).each { |r| avg.push(r.time_s) }
      avg.average
    end

    def num_results
      @num_results ||= results.length
    end

    def recently
      @now - RECENCY_THRESHOLD_SECONDS
    end

    def num_recent_results
      @num_recent_results ||= results.count { |r| r.timestamp >= recently }
    end

    def averages
      @averages ||= compute_averages(grouped_results)
    end

    def old_averages
      @old_averages ||= compute_averages(old_grouped_results)
    end

    private

    def compute_averages(grouped_results)
      grouped_averages = grouped_results.collect { |c, rs| [c, average_time(rs)] }
      grouped_averages.sort_by { |t| -t[1] }.freeze
    end

    def mode
      @mode ||= BufferHelper.mode_for_options(@options)
    end

    def results
      @results ||= @results_persistence.load_results(mode).freeze
    end
    
    def old_results
      @old_results ||= results.select { |r| r.timestamp < recently }
    end

    def grouped_results
      @grouped_results ||= group_results(results)
    end

    def old_grouped_results
      @old_grouped_results ||= group_results(old_results)
    end

    def group_results(results)
      results.group_by(&:input_representation).freeze
    end

    # Interesting time boundaries to see the number of bad results above that boundary.
    # It allows to display things like "9 results are above 4.5 and one result is above 5".
    def cutoffs
      return [] if averages.length < 20

      # TODO: Take mode and target into account
      some_bad_result = averages[9][1]
      step = floor_to_nice(some_bad_result / 10)
      start = floor_to_step(some_bad_result, step)
      finish = start + step * 5
      start.step(finish, step).to_a
    end
  end
end
