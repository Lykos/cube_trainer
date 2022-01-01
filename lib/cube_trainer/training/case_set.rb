# frozen_string_literal: true

require_relative 'case_pattern'
require 'twisty_puzzles'
require 'twisty_puzzles/utils'

module CubeTrainer
  module Training
    # Helpers included for all case sets.
    module CaseSetHelper
      include CasePatternDsl

      def match?(casee)
        pattern.match?(casee)
      end

      def eql?(other)
        self.class.equal?(other.class) && pattern == other.pattern
      end

      alias == eql?

      def hash
        [self.class, pattern].hash
      end

      def pattern
        raise NotImplementedError
      end
    end

    # A high level case set like edge 3-cycles.
    # This is not used for training, look for `ConcreteAlgSet` for one that includes a buffer
    # and can be used for training.
    class AbstractCaseSet
      include CaseSetHelper

      def fixed_parts_refinements(casee)
        raise NotImplementedError
      end

      def refinement
        raise NotImplementedError
      end
    end

    # A concrete case set like edge 3-cycles for buffer UF.
    # This is used for training and parsing alg sets.
    class ConcreteCaseSet
      extend TwistyPuzzles::Utils::StringHelper
      include CaseSetHelper
      include TwistyPuzzles::Utils::StringHelper

      SEPARATOR = ':'

      def row_pattern(refinement_index, casee)
        raise NotImplementedError
      end

      def to_raw_data
        ([simple_class_name(self.class)] + to_raw_data_parts_internal).join(SEPARATOR)
      end

      def self.from_raw_data(raw_data)
        raw_clazz, *raw_data_parts = raw_data.split(SEPARATOR)
        clazz = CONCRETE_CASE_SET_NAME_TO_CLASS[raw_clazz]
        raise ArgumentError, "Unknown concrete case set class #{raw_clazz}." unless clazz

        clazz.from_raw_data_parts(raw_data_parts)
      end

      def to_raw_data_parts_internal
        raise NotImplementedError
      end

      def case_name(casee, letter_scheme: nil)
        raise NotImplementedError
      end

      # Stricter version of `match?` that doesn't necessarily match equivalent cases.
      # E.g. for 3 cycles, this only matches cases that start with the right buffer
      # and doesn't match 
      def strict_match?(casee)
        raise NotImplementedError
      end

      # Creates an equivalent case that fulfills `strict_match?`.
      def create_strict_matching(casee)
        raise NotImplementedError
      end

      def default_cube_size
        raise NotImplementedError
      end
    end

    # An alg set with all 3 cycles of a given part type.
    class ThreeCycleSet < AbstractCaseSet
      def initialize(part_type)
        super()
        @pattern = case_pattern(part_cycle_pattern(part_type, wildcard, wildcard, wildcard))
        @part_type = part_type
      end

      attr_reader :part_type, :pattern

      def to_s
        "#{@part_type.name.split('::').last.downcase} 3-cycles"
      end

      def fixed_parts_refinements(casee)
        return [] unless casee.part_cycles.length == 1 && casee.part_cycles.first.length == 3

        buffers = casee.part_cycles.first.parts.map { |p| p.rotations.min }
        buffers.map { |b| refinement(b) }
      end

      def has_buffer?
        true
      end

      def all_refinements
        part_type::ELEMENTS.map { |p| refinement(p) }
      end

      def refinement(part)
        BufferedThreeCycleSet.new(@part_type, part)
      end
    end

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

    CASE_SETS = TwistyPuzzles::PART_TYPES.map { |p| ThreeCycleSet.new(p) }.freeze

    class ConcreteCaseSet
      CONCRETE_CASE_SET_CLASSES = [BufferedThreeCycleSet].freeze
      CONCRETE_CASE_SET_NAME_TO_CLASS =
        CONCRETE_CASE_SET_CLASSES.to_h { |e| [simple_class_name(e), e] }.freeze
    end
  end
end
