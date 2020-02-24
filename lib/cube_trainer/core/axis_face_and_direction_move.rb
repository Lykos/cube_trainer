# frozen_string_literal: true

require 'cube_trainer/core/abstract_move'
require 'cube_trainer/core/cube_direction'

module CubeTrainer
  module Core
    # Intermediate base class for all types of moves that have an axis face and a direction,
    # i.e. cube moves and rotations.
    class AxisFaceAndDirectionMove < AbstractMove
      def initialize(axis_face, direction)
        raise TypeError, "Unsuitable axis face #{axis_face}." unless axis_face.is_a?(Face)
        raise TypeError unless direction.is_a?(CubeDirection)

        @axis_face = axis_face
        @direction = direction
      end

      attr_reader :direction, :axis_face

      def translated_direction(other_axis_face)
        case @axis_face
        when other_axis_face then @direction
        when other_axis_face.opposite then @direction.inverse
        else raise ArgumentError
        end
      end

      def same_axis?(other)
        @axis_face.same_axis?(other.axis_face)
      end

      def identifying_fields
        [@axis_face, @direction]
      end

      def canonical_direction
        @axis_face.canonical_axis_face? ? @direction : @direction.inverse
      end

      def can_swap?(other)
        super || same_axis?(other)
      end

      def swap_internal(other)
        if same_axis?(other)
          [other, self]
        else
          super
        end
      end

      def rotate_by(rotation)
        if same_axis?(rotation)
          self
        else
          rotation_neighbors = rotation.axis_face.neighbors
          face_index = rotation_neighbors.index(@axis_face) || raise
          new_axis_face =
            rotation_neighbors[(face_index + rotation.direction.value) % rotation_neighbors.length]
          fields = replace_once(identifying_fields, @axis_face, new_axis_face)
          self.class.new(*fields)
        end
      end

      def mirror(normal_face)
        if normal_face.same_axis?(@axis_face)
          fields = replace_once(
            replace_once(identifying_fields, @direction, @direction.inverse),
            @axis_face, @axis_face.opposite
          )
          self.class.new(*fields)
        else
          inverse
        end
      end
    end
  end
end
