# frozen_string_literal: true

require 'cube_trainer/core/reversible_applyable'

module CubeTrainer
  module Core
    # Base class for a compiled algorithm for a particular puzzle.
    class CompiledAlgorithm
      include ReversibleApplyable

      def initialize(native)
        raise TypeError unless native.is_a?(self.class::NATIVE_CLASS)

        @native = native
      end

      attr_reader :native
      attr_writer :inverse
      protected :inverse=

      def rotate_by(rotation)
        self.class.new(@native.rotate_by(rotation.axis_face.face_symbol, rotation.direction.value))
      end

      def mirror(normal_face)
        self.class.new(@native.mirror(normal_face.face_symbol))
      end

      def inverse
        @inverse ||= begin
                       alg = self.class.new(@native.inverse)
                       alg.inverse = self
                       alg
                     end
      end

      def +(other)
        self.class.new(@native + other.native)
      end

      def apply_to(state)
        @native.apply_to(state.native)
      end
    end
  end
end
