# frozen_string_literal: true

require 'twisty_puzzles/sticker_cycle'
require 'twisty_puzzles/utils/array_helper'

module TwistyPuzzles
  
    # Factory for sticker cycles given part cycles.
    class PartCycleFactory
      include TwistyPuzzles::Utils::ArrayHelper

      def initialize(cube_size, incarnation_index)
        CubeState.check_cube_size(cube_size)
        unless incarnation_index.is_a?(Integer) && incarnation_index >= 0
          raise ArgumentError, "Invalid incarnation index #{incarnation_index}."
        end

        @cube_size = cube_size
        @incarnation_index = incarnation_index
        @cache = {}
      end

      def coordinates(part)
        @cache[part] ||= Coordinate.solved_positions(part, @cube_size, @incarnation_index)
      end

      def multi_twist(parts)
        unless parts.all? { |p| p.is_a?(Corner) || p.is_a?(Edge) }
          raise TypeError, 'Twists are only supported for edges and corners.'
        end

        cycles = parts.map { |p| StickerCycle.new(@cube_size, coordinates(p)) }
        StickerCycles.new(@cube_size, cycles)
      end

      def check_type_consistency(parts)
        return unless parts.any? { |p| p.class != parts.first.class }

        raise TypeError, "Cycles of heterogenous piece types #{parts.inspect} are not supported."
      end

      def construct(parts)
        if parts.length < 2
          raise ArgumentError, 'Cycles of length smaller than 2 are not supported.'
        end

        unless @incarnation_index < parts.first.num_incarnations(@cube_size)
          raise ArgumentError, "Incarnation index #{@incarnation_index} for cube size " \
                               "#{@cube_size} is not supported for #{parts.first.inspect}."
        end

        check_types(parts, Part)
        check_type_consistency(parts)
        part_coordinates = parts.map { |p| coordinates(p) }
        cycles = part_coordinates.transpose.map { |c| StickerCycle.new(@cube_size, c) }
        StickerCycles.new(@cube_size, cycles)
      end
    end
end
