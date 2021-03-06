# frozen_string_literal: true

require 'cube_trainer/letter_pair'

module CubeTrainer
  # Person Action Object plus a letter pair
  class PaoLetterPair
    SEPARATOR = ':'
    PAO_TYPES = %i[person action object].freeze

    def initialize(pao_type, letter_pair)
      raise ArgumentError unless PAO_TYPES.include?(pao_type)
      raise ArgumentError unless letter_pair.is_a?(LetterPair)

      @pao_type = pao_type
      @letter_pair = letter_pair
    end

    attr_reader :pao_type, :letter_pair

    def letters
      @letter_pair.letters
    end

    def matches_word?(word)
      @letter_pair.matches_word?(word)
    end

    # Construct from data stored in the db.
    def self.from_raw_data(data)
      raw_pao, raw_letter_pair = data.split(SEPARATOR)
      PaoLetterPair.new(raw_pao.to_sym, LetterPair.from_raw_data(raw_letter_pair))
    end

    # Serialize to data stored in the db.
    def to_raw_data
      [@pao_type, @letter_pair.to_raw_data].join(SEPARATOR)
    end

    def to_s
      @to_s ||= "#{@pao_type} #{@letter_pair}"
    end
  end
end
