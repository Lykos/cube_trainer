require 'ui_helpers'

class Result

  def initialize(timestamp, time_s, cubie, failed_attempts)
    @timestamp = timestamp
    @time_s = time_s
    @cubie = cubie
    @failed_attempts = failed_attempts
  end

  COLUMNS = 3

  attr_reader :timestamp, :time_s, :cubie, :failed_attempts

  include UiHelpers

  def formatted_time
    format_time(@time_s)
  end

  def formatted_timestamp
    @timestamp.to_s
  end

  def columns
    [formatted_timestamp, formatted_time, failed_attempts.to_s]
  end
end
