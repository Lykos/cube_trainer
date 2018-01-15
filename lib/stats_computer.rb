require 'cube_average'
require 'math_helper'

module CubeTrainer

  class StatsComputer

    include MathHelper
    
    def initialize(results)
      grouped_results = results.group_by { |c| c.input.to_s }
      grouped_averages = grouped_results.collect { |c, rs| [c, average_time(rs)] }
      @averages = grouped_averages.sort_by { |t| -t[1] }
    end

    attr_reader :averages

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
