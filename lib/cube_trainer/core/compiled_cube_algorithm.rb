# frozen_string_literal: true

require 'cube_trainer/core/compiled_algorithm'

module CubeTrainer
  module Core
    # Wrapper of the native C implementation of a compiled algorithm for a particular cube size.
    class CompiledCubeAlgorithm < CompiledAlgorithm
      def self.transform_rotation(move, cube_size)
        slice_moves =
          0.upto(cube_size - 1).map do |i|
            [:slice, move.axis_face.face_symbol, move.direction.value, i]
          end
        [
          [:face, move.axis_face.face_symbol, move.direction.value],
          [:face, move.axis_face.opposite.face_symbol, move.direction.inverse.value]
        ] + slice_moves
      end

      def self.transform_fat_mslice_move(move, cube_size)
        1.upto(cube_size - 2).map do |i|
          [:slice, move.axis_face.face_symbol, move.direction.value, i]
        end
      end

      def self.transform_slice_move(move)
        [
          [:slice, move.axis_face.face_symbol, move.direction.value, move.slice_index]
        ]
      end

      def self.transform_fat_move(move)
        slice_moves =
          0.upto(move.width - 1).map do |i|
            [:slice, move.axis_face.face_symbol, move.direction.value, i]
          end
        [
          [:face, move.axis_face.face_symbol, move.direction.value]
        ] + slice_moves
      end

      private_class_method :transform_rotation, :transform_fat_mslice_move, :transform_slice_move,
                           :transform_fat_move

      def self.transform_move(move, cube_size)
        decided_move = move.decide_meaning(cube_size)
        case decided_move
        when Rotation then transform_rotation(decided_move, cube_size)
        when FatMSliceMove then transform_fat_mslice_move(decided_move, cube_size)
        # Note that this also covers InnerMSliceMove
        when SliceMove then transform_slice_move(decided_move)
        when FatMove then transform_fat_move(decided_move)
        else
          raise TypeError, "Invalid move type #{move.class} that becomes #{decided_move.class} "\
                           "for cube size #{cube_size}."
        end
      end

      def self.for_moves(cube_size, moves)
        transformed_moves = moves.collect_concat { |m| transform_move(m, cube_size) }
        native = Native::CubeAlgorithm.new(cube_size, transformed_moves)
        new(native)
      end

      NATIVE_CLASS = Native::CubeAlgorithm
    end
  end
end
