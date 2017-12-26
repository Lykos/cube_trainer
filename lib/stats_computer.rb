require 'cube_average'

class StatsComputer

  def compute_stats(results)
    grouped_results = results.group_by { |c| c.input.to_s }
    grouped_averages = grouped_results.collect { |c, rs| [c, average_time(rs)] }
    grouped_averages.sort_by { |t| -t[1] }
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
