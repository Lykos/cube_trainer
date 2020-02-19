# frozen_string_literal: true

module CubeTrainer
  # Base class of names of algorithm cases, e.g. 'Ja' or 'U2 + Ja'.
  class AlgName
    SEPARATOR = ' + '
    OPENING_BRACKET = '('
    CLOSING_BRACKET = '('
    RESERVED_STUFF = [SEPARATOR, OPENING_BRACKET, CLOSING_BRACKET].freeze

    def self.bracketed(stuff)
      OPENING_BRACKET + stuff.to_s + CLOSING_BRACKET
    end

    def to_s
      raise NotImplementedError
    end

    def bracketed_if_needed_to_s
      raise NotImplementedError
    end

    def self.from_raw_data(input)
      if input.include?(OPENING_BRACKET) || input.include?(CLOSING_BRACKET)
        raise NotImplementedError
      end

      if input.include?(SEPARATOR)
        CombinedAlgName.new(input.split(SEPARATOR))
      else
        SimpleAlgName.new(input)
      end
    end

    def to_raw_data
      to_s
    end

    def eql?(other)
      self.class.equal?(other.class) && to_s == other.to_s
    end

    alias == eql?

    def hash
      @hash ||= [self.class, to_s].hash
    end

    def +(other)
      CombinedAlgName.new([self, other])
    end
  end

  # Simple names of algorithm cases, e.g. 'Ja'.
  class SimpleAlgName < AlgName
    def initialize(name)
      raise ArgumentError if name.include?(SEPARATOR)

      @to_s = name
    end

    attr_reader :to_s

    def bracketed_if_needed_to_s
      to_s
    end
  end

  # Combined names of algorithm cases, e.g. 'U2 + Ja'.
  class CombinedAlgName < AlgName
    def initialize(sub_names)
      @sub_names = sub_names
    end

    attr_reader :sub_names

    def to_s
      @sub_names.join(SEPARATOR)
    end

    def to_raw_data
      @sub_names.map(&:bracketed_if_needed_to_s).join(SEPARATOR)
    end

    def bracketed_if_needed_to_s
      AlgName.bracketed(to_s)
    end
  end
end
