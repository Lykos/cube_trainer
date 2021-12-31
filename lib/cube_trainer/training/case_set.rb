require_relative 'case_pattern'

module CubeTrainer
  module Training
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

    # A high level case set like 3-cycles.
    # This is not used for training, look for `ConcreteAlgSet` for one that includes a buffer
    # and can be used for training.
    class AbstractCaseSet
      include CaseSetHelper

      def fixed_parts_refinements(casee)
        raise NotImplementedError
      end

      # An alg set can affect multiple part types, e.g. a parity.
      # This is the main part type.
      def part_type
        raise NotImplementedError
      end
    end

    class ConcreteCaseSet
      include CaseSetHelper

      def buffer
        raise NotImplementedError
      end

      def row_pattern(refinement_index, casee)
        raise NotImplementedError
      end
    end

    class ThreeCycleSet < AbstractCaseSet
      def initialize(part_type)
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
        buffers.map { |b| BufferedThreeCycleSet.new(@part_type, b) }
      end
    end

    class BufferedThreeCycleSet < ConcreteCaseSet
      def initialize(part_type, buffer)
        @pattern = case_pattern(part_cycle_pattern(part_type, specific_part(buffer), wildcard, wildcard))
        @part_type = part_type
        @buffer = buffer
      end

      attr_reader :part_type, :buffer, :pattern

      def to_s
        "#{@part_type.name.split('::').last.downcase} 3-cycles for buffer #{@buffer}"
      end

      def row_pattern(refinement_index, casee)
        raise ArgumentError if refinement_index != 0 && refinement_index != 1
        raise ArgumentError unless casee.part_cycles.length == 1 && casee.part_cycles.first.length == 3

        part_patterns = [specific_part(@buffer), wildcard, wildcard]
        refined_part = casee.part_cycles.first.start_with(@buffer).parts[refinement_index + 1]
        part_patterns[refinement_index + 1] = specific_part(refined_part)
        case_pattern(part_cycle_pattern(@part_type, *part_patterns))
      end
    end

    CASE_SETS = TwistyPuzzles::PART_TYPES.map { |p| ThreeCycleSet.new(p) }.freeze
  end
end
