require 'ui_helpers'
require 'pao_letter_pair'
require 'letter_pair'

module CubeTrainer

  # TODO refactor this to properly include the mode
  class Result
    def initialize(mode, timestamp, time_s, input, failed_attempts, word)
      raise unless mode.is_a?(Symbol)
      @mode = mode
      raise unless timestamp.is_a?(Time)
      @timestamp = timestamp
      raise unless time_s.is_a?(Float)
      @time_s = time_s
      raise unless input.is_a?(LetterPair) || input.is_a?(PaoLetterPair)
      @input = input
      raise unless failed_attempts.is_a?(Integer)
      @failed_attempts = failed_attempts
      raise unless word.nil? || word.is_a?(String)
      @word = word
    end
  
    # Construct from data stored in the db.
    def self.from_raw_data(data)
      raw_mode, timestamp, time_s, raw_input, failed_attempts, word = data
      mode = raw_mode.to_sym
      Result.new(mode, Time.at(timestamp), time_s, parse_input(mode, raw_input), failed_attempts, word)
    end

    def self.parse_input(mode, input)
      case mode
      when :letters_to_word
        PaoLetterPair.from_raw_data(input)
      else
        LetterPair.from_raw_data(input)
      end
    end
  
    # Serialize to data stored in the db.
    def to_raw_data
      [@mode.to_s, @timestamp.to_i, @time_s, @input.to_raw_data, @failed_attempts, @word]
    end
  
    # Number of columns in the UI.
    COLUMNS = 3
  
    attr_reader :mode, :timestamp, :time_s, :input, :failed_attempts, :word
  
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
  
    # Columns that are displayed in the UI.
    def columns
      [formatted_timestamp, formatted_time, failed_attempts.to_s]
    end
  end

end
