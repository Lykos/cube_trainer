# frozen_string_literal: true

require 'cube_trainer/utils/array_helper'

module CubeTrainer
  module Training
    # Class that takes a list of input items and figures out which input item a
    # given alg belongs to.
    class AlgSetReverseEngineer
      include Utils::ArrayHelper

      def initialize(input_items, color_scheme, cube_size)
        @input_items = input_items
        @state = color_scheme.solved_cube_state(cube_size)
      end

      def find_stuff(alg)
        alg.apply_temporarily_to(@state) do |state|
          @input_items.find do |i|
            i.cube_state == state
          end&.representation
        end
      end
    end
  end
end
