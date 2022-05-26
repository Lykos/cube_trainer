# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles/utils'

module CaseSets
  # An alg set with all flaoting two twists of a given part type.
  class ConcreteFloatingTwoTwistSet < ConcreteCaseSet
    include TwistNameHelper

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

    def buffer; end

    def eql?(other)
      self.class.equal?(other.class) && @part_type == other.part_type
    end

    def hash
      @hash ||= [self.class, @part_type].hash
    end

    def to_s
      twist_name = part_type == TwistyPuzzles::Edge ? 'flip' : 'twist'
      "floating #{simple_class_name(@part_type).downcase} #{twist_name}s"
    end

    def row_pattern(refinement_index, casee)
      raise ArgumentError if refinement_index != 0 && refinement_index != 1
      raise ArgumentError unless match?(casee)

      desired_twist = refinement_twist(refinement_index)
      other_twist = inverse_twist(desired_twist)
      part = twisted_part(casee, desired_twist)
      specific_part_pattern = specific_part(part)
      specific_cycle_pattern = part_cycle_pattern(
        @part_type, specific_part_pattern,
        twist: specific_twist(desired_twist)
      )
      wildcard_cycle_pattern = part_cycle_pattern(
        @part_type, wildcard,
        twist: specific_twist(other_twist)
      )
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
      raise ArgumentError unless match?(casee)

      parts = casee.part_cycles.map { |c| c.parts.first }
      name_parts = letter_scheme ? parts.map { |p| letter_scheme.letter(p) || p } : parts
      name_parts.join(' ')
    end

    def raw_case_name(casee)
      raise ArgumentError unless match?(casee)

      twist_names = casee.part_cycles.map { |c| twist_name(c) }
      twist_names.join(' ')
    end

    def default_cube_size
      [@part_type.min_cube_size, 3].max
    end

    def cases
      twist_parts = @part_type::ELEMENTS.select { |a| a == a.rotations.min }
      part_permutations = twist_parts.permutation(2).reject { |a, b| a == b }
      part_permutations.select! { |a, b| a < b } if inverse_twist(1) == 1
      lol = part_permutations.map do |parts|
        Case.new(
          part_cycles: [
            TwistyPuzzles::PartCycle.new([parts[0]], 1),
            TwistyPuzzles::PartCycle.new([parts[1]], inverse_twist(1))
          ]
        )
      end
      p lol
      lol
    end

    private

    def twisted_part(casee, twist)
      cycle = casee.part_cycles.find { |c| c.length == 1 && c.twist == twist }
      cycle&.parts&.first
    end

    def refinement_twist(refinement_index)
      [1, inverse_twist(1)][refinement_index]
    end

    def inverse_twist(twist)
      @part_type::ELEMENTS.first.rotations.length - twist
    end
  end
end
