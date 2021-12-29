# frozen_string_literal: true

require 'twisty_puzzles/utils'

module CubeTrainer
  module Training
    # Class that takes a list of input items and figures out which input item a
    # given alg belongs to.
    class AlgSetReverseEngineer
      include TwistyPuzzles::Utils::ArrayHelper

      def initialize(input_items, training_session)
        @input_items = input_items
        @state = training_session.solved_cube_state
      end

      def find_stuff(alg)
        alg.apply_temporarily_to(@state) do |state|
          @input_items.find do |i|
            i.cube_state == state
          end&.case_key
        end
      end
    end
  end
end
