require 'ui_helpers'

class Result

  def initialize(timestamp, time_s, cubie)
    @timestamp = timestamp
    @time_s = time_s
    @cubie = cubie
  end

  COLUMNS = 2

  attr_reader :timestamp, :time_s, :cubie

  include UiHelpers

  def formatted_time
    format_time(@time_s)
  end

  def formatted_timestamp
    @timestamp.to_s
  end

  def columns
    [formatted_timestamp, formatted_time]
  end

  def to_h
    {:timestamp => timestamp, :time_s => time_s, :cubie => cubie}
  end

  def self.from_h(h)
    self.new(h[:timestamp], h[:time_s], h[:cubie])
  end
end
