# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles/utils'

module CubeTrainer
  module Types
    # Active record type for an array of parts.
    class PartsType < ActiveRecord::Type::String
      SEPARATOR = ' '

      def part_type
        @part_type ||= PartType.new
      end

      def cast(value)
        return [] if value.blank?
        return value if value.is_a?(Array) && value.all?(TwistyPuzzles::Part)
        raise TypeError unless value.is_a?(String) || value.is_a?(Symbol)

        raw_parts = value.split(SEPARATOR)
        raw_parts.map { |p| part_type.cast(p) }
      end

      def serialize(value)
        return if value.nil?

        value = cast(value) unless value.is_a?(Array) && value.all?(TwistyPuzzles::Part)
        value.map { |v| part_type.serialize(v) }.join(SEPARATOR)
      end
    end
  end
end
