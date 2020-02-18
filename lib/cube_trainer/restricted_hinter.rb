# frozen_string_literal: true

module CubeTrainer
  # A restricted hinter that works like a given hinter, but only works on a certain set of inputs.
  class RestrictedHinter
    def initialize(inputs, hinter)
      raise TypeError, "Invalid input type #{inputs.class}." unless inputs.respond_to?(:include?)
      raise TypeError, "Invalid hinter type #{hinter.class}." unless hinter.respond_to?(:hints)

      @inputs = inputs
      @hinter = hinter
      return unless hinter.respond_to?(:entries)

      @entries = @hinter.entries.select { |a, _b| in_domain?(a) }
      self.class.attr_reader :entries
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
