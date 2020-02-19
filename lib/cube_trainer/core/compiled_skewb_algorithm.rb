# frozen_string_literal: true

require 'cube_trainer/core/compiled_algorithm'

module CubeTrainer
  module Core
    # Wrapper of the native C implementation of a compiled algorithm for a particular cube size.
    class CompiledSkewbAlgorithm < CompiledAlgorithm
      def self.transform_move(move)
        case move
        when Rotation
          [:rotation, move.axis_face.face_symbol, move.direction.value]
        when SkewbMove
          [:move, move.axis_corner.face_symbols, move.direction.value]
        else
          raise TypeError
        end
      end

      def self.for_moves(moves)
        native = Native::SkewbAlgorithm.new(moves.map { |m| transform_move(m) })
        new(native)
      end

      NATIVE_CLASS = Native::SkewbAlgorithm
      EMPTY = for_moves([])
    end
  end
end
