# frozen_string_literal: true

require 'cube_trainer/core/abstract_move'
require 'cube_trainer/core/cube'
require 'cube_trainer/core/skewb_direction'
require 'cube_trainer/core/puzzle'

module CubeTrainer
  module Core
    # Base class for skewb moves.
    class SkewbMove < AbstractMove
      def initialize(axis_corner, direction)
        raise TypeError unless axis_corner.is_a?(Corner)
        raise TypeError unless direction.is_a?(SkewbDirection)

        @axis_corner = axis_corner.rotate_face_up(axis_corner.faces.min_by { |f| f.piece_index })
        @direction = direction
      end

      def puzzles
        [Puzzle::SKEWB]
      end

      attr_reader :axis_corner, :direction

      def to_s
        "#{@axis_corner}#{@direction.name}"
      end

      def slice_move?
        false
      end

      def identifying_fields
        [@axis_corner, @direction]
      end

      def rotate_by(rotation)
        nice_face =
          find_only(@axis_corner.adjacent_faces) do |f|
            f.same_axis?(rotation.axis_face)
          end
        nice_direction = rotation.translated_direction(nice_face)
        nice_face_corners = nice_face.clockwise_corners
        on_nice_face_index = nice_face_corners.index { |c| c.turned_equals?(@axis_corner) }
        new_corner =
          nice_face_corners[(on_nice_face_index + nice_direction.value) % nice_face_corners.length]
        self.class.new(new_corner, @direction)
      end

      def mirror(normal_face)
        faces = @axis_corner.adjacent_faces
        replaced_face = find_only(faces) { |f| f.same_axis?(normal_face) }
        new_corner =
          Corner.between_faces(replace_once(faces, replaced_face, replaced_face.opposite))
        self.class.new(new_corner, @direction.inverse)
      end
    end
  end
end
