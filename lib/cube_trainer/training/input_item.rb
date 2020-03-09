# frozen_string_literal: true

module CubeTrainer
  module Training
    # An input item that has a representation that will be stored and used as a key and
    # potentially an associated cube state.
    class InputItem
      def initialize(representation, cube_state = nil)
        @representation = representation
        @cube_state = cube_state
      end

      # The representation of this input item. This is a short thing that is the identity of the
      # input item. This can be a letter pair or an alg name.
      attr_reader :representation

      # An (optional) cube state that represents this input item.
      attr_reader :cube_state
    end
  end
end
