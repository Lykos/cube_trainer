# frozen_string_literal: true

require 'twisty_puzzles'

module CaseSets
  # An alg set with 3 cycles with a given fixed buffer.
  class BufferedThreeTwistSet < ConcreteCaseSet
    def initialize(buffer)
      super()
      @part_type = TwistyPuzzles::Corner
      @pattern = pattern_for_direction(1) | three_cycle_pattern_for_direction(inverse_twist(1))
      @buffer = buffer
    end

    attr_reader :part_type, :buffer, :pattern

    def eql?(other)
      self.class.equal?(other.class) && @part_type == other.part_type && @buffer == other.buffer
    end

    def hash
      @hash ||= [self.class, @part_type, @buffer].hash
    end

    def to_s
      "#{simple_class_name(@part_type).downcase} 3-twists for buffer #{@buffer}"
    end

    def row_pattern(refinement_index, casee)
      raise ArgumentError if refinement_index != 0 && refinement_index != 1
      return false unless casee.part_cycles.length == 3
      return false unless casee.part_cycles.all? { |c| c.length == 1 }

      direction = refinement_index == 0 ? 1 : inverse_twist(1)
      other_parts = casee.part_cycles.map(&:first).select { |p| p != buffer }
      other_parts.map { |p| row_pattern_for_part(direction, p) }.reduce(:|)
    end

    def self.from_raw_data_parts(raw_data)
      unless raw_data.length == 2
        raise ArgumentError,
              "expected 2 parts, got #{raw_data.join(', ')}"
      end

      part_type = TwistyPuzzles::PART_TYPES.find { |t| simple_class_name(t) == raw_data[0] }
      raise ArgumentError unless part_type

      buffer = part_type.parse(raw_data[1])
      new(part_type, buffer)
    end

    def to_raw_data_parts_internal
      [simple_class_name(@part_type), @buffer.to_s]
    end

    def strict_match?(casee)
      return false unless casee.part_cycles.length == 3
      return false unless casee.part_cycles.all? { |c| c.length == 1 }
      return false unless casee.part_cycles.all? { |c| c.part_type == @part_type }
      return false unless match?(casee)

      casee.part_cycles.first.parts.first == @buffer
    end

    def create_strict_matching(casee)
      raise ArgumentError unless match?(casee)

      Case.new(part_cycles: casee.part_cycles.sort_by { |c| c.start_with(@buffer) ? 0 : 1 })
    end

    def case_name(casee, letter_scheme: nil)
      return false unless casee.part_cycles.length == 3
      return false unless casee.part_cycles.all? { |c| c.length == 1 }
      return false unless casee.part_cycles.all? { |c| c.part_type == @part_type }

      parts = casee.part_cycles[1..2].map(&:first)
      name_parts = letter_scheme ? parts.map { |p| letter_scheme.letter(p) || p } : parts
      name_parts.join(' ')
    end

    def raw_case_name(casee)
      return false unless casee.part_cycles.length == 3
      return false unless casee.part_cycles.all? { |c| c.length == 1 }
      return false unless casee.part_cycles.all? { |c| c.part_type == @part_type }

      parts = casee.part_cycles.first.parts
      parts.join(' ⟶ ')
    end

    def default_cube_size
      [@part_type.min_cube_size, 3].max
    end

    def cases
      part_permutations =
        @part_type::ELEMENTS.permutation(2).select do |a, b|
          # Exclude duplicates of the buffer or duplicates between the two targets.
          !a.turned_equals?(b) && !a.turned_equals?(buffer) && !b.turned_equals?(buffer)
        end
      part_permutations.collect_concat do |parts|
        [
          case_for_direction(parts, 1),
          case_for_direction(parts, inverse_twist(1))
        ]
      end
    end

    def axis_order_matters?
      true
    end

    private

    def case_for_direction(parts, direction)
      Case.new(part_cycles: ([@buffer] + parts).map { |p| TwistyPuzzles::PartCycle.new([p], twist: direction) })
    end

    def pattern_for_direction(direction)
      case_pattern(
        part_cycle_pattern(@part_type, specific_part(buffer), twist: specific_twist(direction)),
        part_cycle_pattern(@part_type, wildcard, twist: specific_twist(direction)),
        part_cycle_pattern(@part_type, wildcard, twist: specific_twist(direction))
      )
    end

    def row_pattern_for_part(direction)
      case_pattern(
        part_cycle_pattern(@part_type, specific_part(buffer), twist: specific_twist(direction)),
        part_cycle_pattern(@part_type, specific_part(other_part), twist: specific_twist(direction)),
        part_cycle_pattern(@part_type, wildcard, twist: specific_twist(direction))
      )
    end

    def refined_part(refinement_index, casee)
      casee.part_cycles.first.start_with(@buffer).parts[refinement_index + 1]
    end
  end
end
