require 'ui_helpers'
require 'pao_letter_pair'
require 'letter_pair'
require 'letter_pair_sequence'
require 'alg_name'
require 'input_item'

module CubeTrainer

  # The part of the result that basically comes from the input of whoever is
  # learning.
  PartialResult = Struct.new(:time_s, :failed_attempts, :word)

  class Result
    def initialize(mode, timestamp, time_s, input_representation, failed_attempts, word)
      raise ArgumentError, "Invalid mode #{mode}." unless mode.is_a?(Symbol)
      @mode = mode
      raise ArgumentError, "Invalid timestamp #{timestamp}." unless timestamp.is_a?(Time)
      @timestamp = timestamp
      raise ArgumentError, "Invalid time_s #{time_s}." unless time_s.is_a?(Float)
      @time_s = time_s
      unless input_representation.is_a?(LetterPair) || input_representation.is_a?(PaoLetterPair) || input_representation.is_a?(AlgName) || input_representation.is_a?(LetterPairSequence)
        raise ArgumentError, "Invalid input representation #{input_representation}."
      end
      @input_representation = input_representation
      raise ArgumentError, "Invalid failed attempts #{failed_attempts}." unless failed_attempts.is_a?(Integer)
      @failed_attempts = failed_attempts
      raise ArgumentError, "Invalid word #{word}." unless word.nil? || word.is_a?(String)
      @word = word
    end

    def self.from_partial(mode, timestamp, partial_result, input_representation)
      new(mode, timestamp, partial_result.time_s, input_representation, partial_result.failed_attempts, partial_result.word)
    end
  
    # Construct from data stored in the db.
    def self.from_raw_data(data)
      raw_mode, timestamp, time_s, raw_input, failed_attempts, word = data
      mode = raw_mode.to_sym
      Result.new(mode, Time.at(timestamp), time_s, parse_input_representation(mode, raw_input), failed_attempts, word)
    end

    def self.parse_input_representation(mode, raw_input)
      case mode
      when :letters_to_word
        PaoLetterPair.from_raw_data(raw_input)
      when :plls_by_name, :oh_plls_by_name
        AlgName.from_raw_data(raw_input)
      when :corner_twists_plus_parities_ul_ub
        LetterPairSequence.from_raw_data(raw_input)
      else
        LetterPair.from_raw_data(raw_input)
      end
    end
  
    # Serialize to data stored in the db.
    def to_raw_data
      [@mode.to_s, @timestamp.to_i, @time_s, @input_representation.to_raw_data, @failed_attempts, @word]
    end
  
    # Number of columns in the UI.
    COLUMNS = 3
  
    attr_reader :mode, :timestamp, :time_s, :input_representation, :failed_attempts, :word
  
    include UiHelpers
  
    def formatted_time
      format_time(@time_s)
    end
  
    def with_word(new_word)
      Result.new(@timestamp, @time_s, @input_representation, @failed_attempts, new_word)
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
