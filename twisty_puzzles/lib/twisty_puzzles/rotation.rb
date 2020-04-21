# frozen_string_literal: true

require 'twisty_puzzles/algorithm'
require 'twisty_puzzles/axis_face_and_direction_move'
require 'twisty_puzzles/cube'
require 'twisty_puzzles/cube_direction'
require 'twisty_puzzles/cube_move'
require 'twisty_puzzles/puzzle'

module TwistyPuzzles
  
    # A rotation of a Skewb or cube.
    class Rotation < AxisFaceAndDirectionMove
      ALL_ROTATIONS = Face::ELEMENTS.product(CubeDirection::ALL_DIRECTIONS).map { |f, d| new(f, d) }
      NON_ZERO_ROTATIONS =
        Face::ELEMENTS.product(CubeDirection::NON_ZERO_DIRECTIONS).map { |f, d| new(f, d) }
      LEFT = new(Face::U, CubeDirection::BACKWARD)
      RIGHT = new(Face::U, CubeDirection::FORWARD)

      # Translates a Skewb direction into a cube direction.
      def self.translated_direction(direction)
        case direction
        when SkewbDirection::ZERO then CubeDirection::ZERO
        when SkewbDirection::FORWARD then CubeDirection::FORWARD
        when SkewbDirection::BACKWARD then CubeDirection::BACKWARD
        end
      end

      # Returns an algorithm consisting of two rotations that are equivalent to rotating
      # the puzzle around a corner.
      # Takes a Skewb direction as an argument (even for cubes) because rotating around
      # is like a Skewb move given that it's modulo 3.
      def self.around_corner(corner, skewb_direction)
        raise TypeError unless corner.is_a?(Corner)
        raise TypeError unless skewb_direction.is_a?(SkewbDirection)

        direction = translated_direction(skewb_direction)

        Algorithm.new([
                        Rotation.new(corner.faces[skewb_direction.value], direction),
                        Rotation.new(corner.faces[0], direction)
                      ])
      end

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
          remaining_face =
            Face::ELEMENTS.find { |f| !used_axis_priorities.include?(f.axis_priority) }
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
