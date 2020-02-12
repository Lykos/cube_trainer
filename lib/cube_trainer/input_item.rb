# frozen_string_literal: true

module CubeTrainer
  class InputItem
    def initialize(representation, cube_state = nil)
      @representation = representation
      @cube_state = cube_state
    end

    # The representation of this input item. This is a short thing that is the identity of the input item. This can be a letter pair or an alg name.
    attr_reader :representation

    # An (optional) cube state that represents this input item.
    attr_reader :cube_state
  end
end
