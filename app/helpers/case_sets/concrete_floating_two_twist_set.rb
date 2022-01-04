# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles/utils'

module CaseSets
  # An alg set with all flaoting two twists of a given part type.
  class ConcreteFloatingTwoTwistSet < ConcreteCaseSet
    def initialize(part_type)
      super()
      @part_type = part_type
      @pattern =
        case_pattern(
          part_cycle_pattern(part_type, wildcard, twist: specific_twist(1)),
          part_cycle_pattern(part_type, wildcard, twist: specific_twist(inverse_twist(1)))
        )
    end

    attr_reader :part_type, :pattern

    def to_s
      "floating #{simple_class_name(@part_type).downcase} 2-cycles"
    end

    def row_pattern(refinement_index, casee)
      raise ArgumentError if refinement_index != 0 && refinement_index != 1
      raise ArgumentError unless casee.part_cycles.length == 2
      raise ArgumentError unless casee.part_cycles.all? { |c| c.part_type == @part_type && c.length == 1 && c.twist > 0 }

      desired_twist = [1, inverse_twist(1)][refinement_index]
      other_twist = inverse_twist(desired_twist)
      cycle = casee.part_cycles.find { |c| c.twist == desired_twist }
      specific_part_pattern = specific_part(cycle.parts.first)
      specific_cycle_pattern = part_cycle_pattern(@part_type, specific_part_pattern, twist: desired_twist)
      wildcard_cycle_pattern = part_cycle_pattern(@part_type, wildcard, twist: other_twist)
      case_pattern(specific_cycle_pattern, wildcard_cycle_pattern)
    end

    def self.from_raw_data_parts(raw_data)
      unless raw_data.length == 1
        raise ArgumentError,
              "expected 1 parts, got #{raw_data.join(', ')}"
      end

      part_type = TwistyPuzzles::PART_TYPES.find { |t| simple_class_name(t) == raw_data.first }
      raise ArgumentError unless part_type

      new(part_type)
    end

    def to_raw_data_parts_internal
      [simple_class_name(@part_type)]
    end

    alias strict_match? match?

    def create_strict_matching(casee)
      raise ArgumentError unless match?(casee)

      casee
    end

    def case_name(casee, letter_scheme: nil)
      raise ArgumentError, "#{casee} is not a floating 2-twist case" unless casee.part_cycles.length == 2
      raise ArgumentError unless casee.part_cycles.all? { |c| c.part_type == @part_type && c.length == 1 && c.twist > 0 }

      parts = casee.part_cycles.map { |c| c.parts.first }
      name_parts = letter_scheme ? parts.map { |p| letter_scheme.letter(p) } : parts
      name_parts.join(' ')
    end

    def default_cube_size
      @part_type.min_cube_size
    end

    def cases
      part_permutations = @part_type::ELEMENTS.permutation(2).select { |a, b| !a.turned_equals?(b) }
      part_permutations.map do |parts|
        Case.new(
          part_cycles: [
            TwistyPuzzles::PartCycle.new([parts[0]], 1),
            TwistyPuzzles::PartCycle.new([parts[1]], inverse_twist(1))
          ]
        )
      end
    end

    private

    def inverse_twist(twist)
      @part_type::ELEMENTS.first.rotations.length - twist
    end
  end
end
