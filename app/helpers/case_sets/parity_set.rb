# frozen_string_literal: true

module CaseSets
  # An alg set with all parities of a given buffer part type and parity part type.
  class ParitySet < AbstractCaseSet
    def initialize(buffer_part_type, parity_part_type)
      super()
      @buffer_part_type = buffer_part_type
      @parity_part_type = parity_part_type
      @pattern =
        case_pattern(
          part_cycle_pattern(buffer_part_type, wildcard, wildcard),
          part_cycle_pattern(parity_part_type, wildcard, wildcard),
        )
    end

    attr_reader :buffer_part_type, :parity_part_type, :pattern

    def to_s
      "#{simple_class_name(@buffer_part_type).downcase} #{simple_class_name(@parity_part_type).downcase} parities"
    end

    def refinements_matching(casee)
      return [] unless casee.part_cycles.length == 2
      return [] unless casee.part_cycles.all? { |c| (c.part_type == @buffer_part_type || c.part_type == @parity_part_type) && c.length == 2 }
      return [] if casee.part_cycles.first.part_type == casee.part_cycles.last.part_type

      buffer_cycle = casee.part_cycles.find { |c| c.part_type == @buffer_part_type }
      buffers = buffer_cycle.parts.map { |p| p.rotations.min }
      buffers.map { |b| refinement(b) }
    end

    def all_refinements
      buffer_part_type::ELEMENTS.map { |p| refinement(p) }
    end

    def refinement(buffer)
      BufferedParitySet.new(@part_type, buffer)
    end

    def buffer?
      true
    end
  end
end
