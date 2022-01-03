# frozen_string_literal: true

module CaseSets
  # An alg set with all 3 cycles of a given part type.
  class ThreeCycleSet < AbstractCaseSet
    def initialize(part_type)
      super()
      @pattern = case_pattern(part_cycle_pattern(part_type, wildcard, wildcard, wildcard))
      @part_type = part_type
    end

    attr_reader :part_type, :pattern

    alias buffer_part_type part_type

    def to_s
      "#{simple_class_name(@part_type).downcase} 3-cycles"
    end

    def refinements_matching(casee)
      return [] unless casee.part_cycles.length == 1 && casee.part_cycles.first.length == 3 && casee.part_cycles.first.part_type == @part_type

      buffers = casee.part_cycles.first.parts.map { |p| p.rotations.min }
      buffers.map { |b| refinement(b) }
    end

    def all_refinements
      part_type::ELEMENTS.map { |p| refinement(p) }
    end

    def refinement(part)
      BufferedThreeCycleSet.new(@part_type, part)
    end

    def buffer?
      true
    end
  end
end
