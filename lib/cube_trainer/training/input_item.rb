# frozen_string_literal: true

require 'twisty_puzzles'

module CubeTrainer
  module Training
    # An input item that has a case key that will be stored and used as a key and
    # potentially an associated cube state.
    # TODO: Move this functionality into Input.
    class InputItem
      def initialize(casee, cube_state = nil)
        casee = Case.new(part_cycles: [casee]) if casee.is_a?(TwistyPuzzles::PartCycle)
        @casee = casee
        @cube_state = cube_state
      end

      # The case of this input item. This is a short thing that is the identity of the
      # input item.
      attr_reader :casee

      # An (optional) cube state that represents this input item.
      attr_reader :cube_state
    end
  end
end
