require 'ui_helpers'

# TODO refactor this to properly include the mode
class Result

  def initialize(timestamp, time_s, input, failed_attempts, word=nil)
    @timestamp = timestamp
    @time_s = time_s
    @input = input
    @failed_attempts = failed_attempts
    @word = word
  end

  COLUMNS = 3

  attr_reader :timestamp, :time_s, :input, :failed_attempts, :word

  include UiHelpers

  def formatted_time
    format_time(@time_s)
  end

  def with_word(new_word)
    Result.new(@timestamp, @time_s, @input, @failed_attempts, new_word)
  end

  def formatted_timestamp
    @timestamp.to_s
  end

  def columns
    [formatted_timestamp, formatted_time, failed_attempts.to_s]
  end
end
