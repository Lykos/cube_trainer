# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles/utils'

module CaseSets

    # An alg set with 3 cycles with a given fixed buffer.
    class BufferedThreeCycleSet < ConcreteCaseSet
      def initialize(part_type, buffer)
        super()
        @pattern = case_pattern(
          part_cycle_pattern(
            part_type, specific_part(buffer), wildcard,
            wildcard
          )
        )
        @part_type = part_type
        @buffer = buffer
      end

      attr_reader :part_type, :buffer, :pattern

      def to_s
        "#{@part_type.name.split('::').last.downcase} 3-cycles for buffer #{@buffer}"
      end

      def row_pattern(refinement_index, casee)
        raise ArgumentError if refinement_index != 0 && refinement_index != 1
        raise ArgumentError unless casee.part_cycles.length == 1
        raise ArgumentError unless casee.part_cycles.first.length == 3

        part_patterns = [specific_part(@buffer), wildcard, wildcard]
        part = refined_part(refinement_index, casee)
        part_patterns[refinement_index + 1] = specific_part(part)
        case_pattern(part_cycle_pattern(@part_type, *part_patterns))
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
        return false unless casee.part_cycles.length == 1
        return false unless casee.part_cycles.first.length == 3
        return false unless casee.part_cycles.first.part_type == @part_type
        return false unless match?(casee)

        casee.part_cycles.first.parts.first == @buffer
      end

      def create_strict_matching(casee)
        raise ArgumentError unless match?(casee)

        Case.new(part_cycles: [casee.part_cycles.first.start_with(@buffer)])
      end

      def case_name(casee, letter_scheme: nil)
        raise ArgumentError unless casee.part_cycles.length == 1
        raise ArgumentError unless casee.part_cycles.first.length == 3

        parts = casee.part_cycles.first.parts[1..2]
        name_parts = letter_scheme ? parts.map { |p| letter_scheme.letter(p) } : parts
        name_parts.join(' ')
      end

      def default_cube_size
        @part_type.min_cube_size
      end

      private

      def refined_part(refinement_index, casee)
        casee.part_cycles.first.start_with(@buffer).parts[refinement_index + 1]
      end
    end
end
