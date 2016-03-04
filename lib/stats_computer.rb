class StatsComputer

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
    values.inject(0.0, :+) / values.length
  end

  def float_times_s(results)
    results.collect { |result| result.time_s }
  end

  def failed_attempts(results)
    results.collect { |result| result.failed_attempts }
  end

end
