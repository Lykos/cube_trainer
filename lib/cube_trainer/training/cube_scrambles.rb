# frozen_string_literal: true

require 'cube_trainer/cube_scrambler'
require 'cube_trainer/training/no_hinter'
require 'cube_trainer/training/scrambler'

module CubeTrainer
  module Training
    # Class that can be used as a generator for a trainer where the generated
    # input items are cube scrambles.
    class CubeScrambles
      # Input sampler where the input items are cube scrambles.
      class InputSampler
        SCRAMBLE_LENGTH = 25

        def initialize(color_scheme)
          @scrambler = CubeScrambler.new
          @cube_state = color_scheme.solved_cube_state(3)
        end

        def random_item
          scramble = @scrambler.random_algorithm(SCRAMBLE_LENGTH)
          InputItem.new(Scramble.new(scramble), scramble.apply_to_dupped(@cube_state))
        end
      end

      def initialize(options)
        @options = options
      end

      def hinter(*)
        @hinter ||= NoHinter.new({})
      end

      def input_sampler(results_model)
        InputSampler.new(@options.color_scheme, results_model, options)
      end

      def input_items
        nil
      end
    end
  end
end
