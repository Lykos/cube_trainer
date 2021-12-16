# frozen_string_literal: true

module CubeTrainer
  module Training
    # An input item that has a case key that will be stored and used as a key and
    # potentially an associated cube state.
    # TODO: Move this functionality into Input.
    class InputItem
      def initialize(case_key, cube_state = nil)
        @case_key = case_key
        @cube_state = cube_state
      end

      # The case key of this input item. This is a short thing that is the identity of the
      # input item. This can be a letter pair or an alg name.
      attr_reader :case_key

      # An (optional) cube state that represents this input item.
      attr_reader :cube_state
    end
  end
end
