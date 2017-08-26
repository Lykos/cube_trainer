class StatsComputer

  NEWER_WEIGHT = 2
  
  def compute_stats(results)
    [
     ['Average Time', average_time(results)],
     ['Average Failed Attempts', average_failed_attempts(results)],
    ]
  end

  def average_time(results)
    average(float_times_s(results))
  end

  def average_failed_attempts(results)
    average(failed_attempts(results))
  end

  def average(values)
    values.reverse.reduce do |avg, b|
      (avg + b * NEWER_WEIGHT) / (NEWER_WEIGHT + 1) 
    end
  end

  def float_times_s(results)
    results.collect { |result| result.time_s }
  end

  def failed_attempts(results)
    results.collect { |result| result.failed_attempts }
  end

end
