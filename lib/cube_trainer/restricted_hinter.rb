# frozen_string_literal: true

module CubeTrainer
  class RestrictedHinter
    def initialize(inputs, hinter)
      unless inputs.respond_to?(:include?)
        raise TypeError, "Invalid input type #{inputs.class}."
      end
      unless hinter.respond_to?(:hints)
        raise TypeError, "Invalid hinter type #{hinter.class}."
      end

      @inputs = inputs
      @hinter = hinter
      if hinter.respond_to?(:entries)
        @entries = @hinter.entries.select { |a, _b| in_domain?(a) }
        self.class.attr_reader :entries
      end
    end

    def self.trivially_restricted(hinter)
      new(hinter.entries.map(&:first), hinter)
    end

    attr_reader :inputs

    def hints(input)
      raise unless in_domain?(input)

      @hinter.hints(input)
    end

    def in_domain?(input)
      @inputs.include?(input)
    end
  end
end
