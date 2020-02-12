# frozen_string_literal: true

require 'cube_trainer/core/compiled_algorithm'

module CubeTrainer
  module Core
    class CompiledCubeAlgorithm < CompiledAlgorithm
      def self.transform_move(move, cube_size)
        decided_move = move.decide_meaning(cube_size)
        if decided_move.is_a?(Rotation)
          slice_moves = 0.upto(cube_size - 1).map do |i|
            [:slice, decided_move.axis_face.face_symbol, decided_move.direction.value, i]
          end
          [
            [:face, decided_move.axis_face.face_symbol, decided_move.direction.value],
            [:face, decided_move.axis_face.opposite.face_symbol, decided_move.direction.inverse.value]
          ] + slice_moves
        elsif decided_move.is_a?(FatMSliceMove)
          1.upto(cube_size - 2).map do |i|
            [:slice, decided_move.axis_face.face_symbol, decided_move.direction.value, i]
          end
        elsif decided_move.is_a?(SliceMove) # Note that this also covers InnerMSliceMove
          [
            [:slice, decided_move.axis_face.face_symbol, decided_move.direction.value, decided_move.slice_index]
          ]
        elsif decided_move.is_a?(FatMove)
          slice_moves = 0.upto(decided_move.width - 1).map do |i|
            [:slice, decided_move.axis_face.face_symbol, decided_move.direction.value, i]
          end
          [
            [:face, decided_move.axis_face.face_symbol, decided_move.direction.value]
          ] + slice_moves
        else
          raise TypeError, "Invalid move type #{move.class} that becomes #{decided_move.class} for cube size #{cube_size}."
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
