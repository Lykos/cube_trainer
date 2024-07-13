# frozen_string_literal: true

module CaseSets
  # An alg set with all corner 3 twists.
  class ThreeTwistSet < AbstractCaseSet
    def initialize
      super
      @part_type = TwistyPuzzles::Corner
      @pattern = pattern_for_direction(1) | pattern_for_direction(2)
    end

    attr_reader :part_type, :pattern

    alias buffer_part_type part_type

    def to_s
      "#{simple_class_name(@part_type).downcase} 3-twist"
    end

    def refinements_matching(casee)
      return [] unless casee.part_cycles.length == 3
      return [] unless casee.part_cycles.all? { |c| c.length == 1 }

      buffers = casee.part_cycles.map { |c| c.parts.first.rotations.min }
      buffers.map { |b| refinement(b) }
    end

    def all_refinements
      part_type::ELEMENTS.map { |p| refinement(p) }
    end

    def refinement(buffer)
      BufferedThreeTwistSet.new(buffer)
    end

    def part_types
      [@part_type]
    end

    private

    def pattern_for_direction(direction)
      case_pattern(
        part_cycle_pattern(@part_type, wildcard, twist: specific_twist(direction)),
        part_cycle_pattern(@part_type, wildcard, twist: specific_twist(direction)),
        part_cycle_pattern(@part_type, wildcard, twist: specific_twist(direction)),
        ignore_same_face_center_cycles: true
      )
    end
  end
end
