# frozen_string_literal: true

require 'twisty_puzzles'

module CubeTrainer
  # A sequence of part cycles.
  class PartCycleSequence
    SEPARATOR = ';'

    raise if TwistyPuzzles::PartCycle::RAW_DATA_RESERVED.include?(SEPARATOR)

    def initialize(part_cycles)
      raise ArgumentError unless part_cycles.all?(TwistyPuzzles::PartCycle)

      @part_cycles = part_cycles
    end

    attr_reader :part_cycles

    # Construct from data stored in the db.
    def self.from_raw_data(data)
      PartCycleSequence.new(data.split(SEPARATOR).map { |d| PartCycleSequence.from_raw_data(d) })
    end

    def contains_any_part?(parts)
      @part_cycles.any? { |ls| ls.contains_any_part?(parts) }
    end

    # Serialize to data stored in the db.
    def to_raw_data
      @part_cycles.join(SEPARATOR)
    end

    def eql?(other)
      self.class.equal?(other.class) && @part_cycles == other.part_cycles
    end

    alias == eql?

    def hash
      @hash ||= ([self.class] + @part_cycles).hash
    end

    def to_s
      @to_s ||= @part_cycles.join(SEPARATOR)
    end
  end
end
