# frozen_string_literal: true

require 'twisty_puzzles/cube_direction'
require 'twisty_puzzles/rotation'

module TwistyPuzzles
  
    AlgorithmTransformation =
      Struct.new(:rotation, :mirror, :mirror_normal_face) do
        def transformed(algorithm)
          algorithm = algorithm.mirror(mirror_normal_face) if mirror
          algorithm.rotate_by(rotation)
        end

        def identity?
          rotation.identity? && !mirror
        end

        # Returns algorithm transformations that mirror an algorithm and rotate it around a face.
        def self.around_face(face)
          around_face_rotations = CubeDirection::ALL_DIRECTIONS.map { |d| Rotation.new(face, d) }
          mirror_normal_face = face.neighbors.first
          around_face_rotations.product([true, false]).map do |r, m|
            AlgorithmTransformation.new(r, m, mirror_normal_face)
          end
        end

        def self.around_face_without_identity(face)
          around_face(face).reject(&:identity?)
        end
      end
  end
end
