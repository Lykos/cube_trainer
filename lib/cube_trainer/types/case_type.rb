# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles/utils'

module CubeTrainer
  module Types
    # Active record type for a case, e.g. one 3-cycle, one parity case,
    # one twist case, one scramble etc.
    # This represents the abstract case independent of its solution.
    class CaseType < ActiveRecord::Type::String
      extend TwistyPuzzles::Utils::StringHelper
      include TwistyPuzzles::Utils::StringHelper

      SEPARATOR = ':'

      def cast(value)
        return if value.nil?
        return value if value.is_a?(Case) || value.is_a?(Scramble)
        raise TypeError unless value.is_a?(String)

        parts = value.split(SEPARATOR)
        # TODO: Get rid of this backwards compatibility logic
        parts.shift if parts.first == 'PartCycle'

        # TODO: Refactor for more future proofness.
        return Scramble.new(algorithm: parts.second) if parts.first == 'Scramble' && parts.length == 2

        part_cycles = parts.map { |raw_data| TwistyPuzzles::PartCycle.from_raw_data(raw_data) }
        Case.new(part_cycles: part_cycles)
      end

      def serialize(value)
        return if value.nil?

        case value
        when Case
          serialize_case(value)
        when Scramble
          serialize_scramble(value)
        else
          raise TypeError, "#{value.class} is not a valid case class"
        end
      end

      private

      def serialize_scramble(value)
        scramble_string = value.algorithm
        raise if scramble_string.include?(SEPARATOR)

        "Scramble#{SEPARATOR}#{scramble_string}"
      end

      def serialize_case(value)
        serialized_parts = value.part_cycles.map(&:to_raw_data)
        raise if serialized_parts.any? { |p| p.include?(SEPARATOR) }

        serialized_parts.join(SEPARATOR)
      end
    end
  end
end
