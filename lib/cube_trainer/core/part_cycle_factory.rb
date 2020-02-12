# frozen_string_literal: true

require 'cube_trainer/core/sticker_cycle'

module CubeTrainer
  module Core
    class PartCycleFactory
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

      def multi_corner_twist(corners)
        unless corners.all? { |p| p.is_a?(Corner) }
          raise TypeError, 'Cycles of weird piece types are not supported.'
      end

        cycles = corners.map { |c| StickerCycle.new(@cube_size, coordinates(c)) }
        StickerCycles.new(@cube_size, cycles)
      end

      def construct(parts)
        unless parts.all? { |p| p.is_a?(Part) }
          raise TypeError, 'Cycles of weird piece types are not supported.'
      end
        if parts.length < 2
          raise ArgumentError, 'Cycles of length smaller than 2 are not supported.'
      end
        if parts.any? { |p| p.class != parts.first.class }
          raise TypeError, "Cycles of heterogenous piece types #{parts.inspect} are not supported."
      end
        unless @incarnation_index < parts.first.num_incarnations(@cube_size)
          raise ArgumentError, "Incarnation index #{@incarnation_index} for cube size #{@cube_size} is not supported for #{parts.first.inspect}."
        end

        part_coordinates = parts.map { |p| coordinates(p) }
        cycles = part_coordinates.transpose.map { |c| StickerCycle.new(@cube_size, c) }
        StickerCycles.new(@cube_size, cycles)
      end
    end
  end
end
