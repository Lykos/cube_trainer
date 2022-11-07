# frozen_string_literal: true

module CaseSets
  # An alg set with all parity twists of a given buffer part type and parity part type.
  class ParityTwistSet < AbstractCaseSet
    def initialize(buffer_part_type, parity_part_type)
      raise TypeError unless buffer_part_type.is_a?(Class)
      raise TypeError unless parity_part_type.is_a?(Class)

      super()
      @buffer_part_type = buffer_part_type
      @parity_part_type = parity_part_type
      @pattern =
        case_pattern(
          part_cycle_pattern(buffer_part_type, wildcard, wildcard),
          part_cycle_pattern(
            buffer_part_type, wildcard, twist: any_unsolved_twist
          ),
          part_cycle_pattern(parity_part_type, wildcard, wildcard),
          ignore_same_face_center_cycles: true
        )
    end

    attr_reader :buffer_part_type, :parity_part_type, :pattern

    def to_s
      "#{simple_class_name(@buffer_part_type).downcase} " \
        "#{simple_class_name(@parity_part_type).downcase} parity twists"
    end

    def refinements_matching(casee)
      return [] unless match?(casee)

      buffer_cycle =
        casee.part_cycles.find do |c|
          c.length == 2 && c.part_type == @buffer_part_type
        end
      buffers = buffer_cycle.parts.map { |p| p.rotations.min }
      buffers.map { |b| refinement(b) }
    end

    def all_refinements
      buffer_part_type::ELEMENTS.map { |p| refinement(p) }
    end

    def refinement(buffer)
      BufferedParityTwistSet.new(@buffer_part_type, @parity_part_type, buffer)
    end

    def part_types
      [@buffer_part_type, @parity_part_type]
    end
  end
end
