# frozen_string_literal: true

require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/axis_face_and_direction_move'
require 'cube_trainer/core/cube'
require 'cube_trainer/core/cube_direction'
require 'cube_trainer/core/cube_move'
require 'cube_trainer/core/puzzle'

module CubeTrainer
  module Core
    # A rotation of a Skewb or cube.
    class Rotation < AxisFaceAndDirectionMove
      ALL_ROTATIONS = Face::ELEMENTS.product(CubeDirection::ALL_DIRECTIONS).map { |f, d| new(f, d) }
      NON_ZERO_ROTATIONS = Face::ELEMENTS.product(CubeDirection::NON_ZERO_DIRECTIONS).map { |f, d| new(f, d) }

      def to_s
        "#{AXES[@axis_face.axis_priority]}#{canonical_direction.name}"
      end

      def puzzles
        [Puzzle::SKEWB, Puzzle::NXN_CUBE]
      end

      def slice_move?
        false
      end

      # Returns an alternative representation of the same rotation
      def alternative
        Rotation.new(@axis_face.opposite, @direction.inverse)
      end

      def equivalent_internal?(other, _cube_size)
        [self, alternative].include?(other)
      end

      def prepend_rotation(other, _cube_size)
        if same_axis?(other)
          direction = translated_direction(other.axis_face)
          Algorithm.move(Rotation.new(other.axis_face, direction + other.direction))
        elsif @direction.double_move? && other.direction.double_move?
          used_axis_priorities = [@axis_face, other.axis_face].map(&:axis_priority)
          # Note that there are two solutions, but any works.
          remaining_face = Face::ELEMENTS.find { |f| !used_axis_priorities.include?(f.axis_priority) }
          Algorithm.move(Rotation.new(remaining_face, CubeDirection::DOUBLE))
        end
      end

      def prepend_fat_m_slice_move(_other, _cube_size)
        nil
      end

      def prepend_fat_move(other, cube_size)
        return unless compatible_fat_move?(other)

        Algorithm.move(
          FatMove.new(other.axis_face.opposite, other.direction, other.inverted_width(cube_size))
        )
      end

      def prepend_slice_move(_other, _cube_size)
        nil
      end

      def move_count(_cube_size, _metric = :htm)
        0
      end

      private

      def compatible_fat_move?(other)
        same_axis?(other) && translated_direction(other.axis_face) == other.direction.inverse
      end
    end
  end
end
