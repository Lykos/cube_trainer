# frozen_string_literal: true

module CubeTrainer
  # Called LetterPair for historical reasons, but actually can contain any number of letters.
  class LetterPair
    SEPARATOR = ' '

    def initialize(letters)
      raise TypeError unless letters.is_a?(Array)
      unless letters.length >= 1
        raise ArgumentError, "Invalid letter pair length for letter pair #{letters.join(' ')}."
      end
      if letters.include?(SEPARATOR)
        raise ArgumentError, "Invalid letter '#{SEPARATOR}' in letter pair #{letters.join(' ')}."
      end

      @letters = letters
    end

    attr_reader :letters

    def contains_any_letter?(letters)
      !(@letters & letters).empty?
    end

    # Construct from data stored in the db.
    def self.from_raw_data(data)
      LetterPair.new(data.split(SEPARATOR))
    end

    # Serialize to data stored in the db.
    def to_raw_data
      @letters.join(SEPARATOR)
    end

    def eql?(other)
      self.class.equal?(other.class) && @letters == other.letters
    end

    alias == eql?

    def hash
      @hash ||= ([self.class] + @letters).hash
    end

    def to_s
      @to_s ||= letters.map(&:capitalize).join(SEPARATOR)
    end

    def regexp
      @regexp ||= Regexp.new('^' + @letters.join('.*'), Regexp::IGNORECASE)
    end

    def matches_word?(word)
      word =~ regexp
    end

    def inverse
      LetterPair.new(@letters.reverse)
    end
  end
end
