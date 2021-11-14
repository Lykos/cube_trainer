# frozen_string_literal: true

require 'cube_trainer/cube_scrambler'
require 'cube_trainer/training/no_hinter'
require 'cube_trainer/training/scramble'

module CubeTrainer
  module Training
    # Class that can be used as a generator for a trainer where the generated
    # input items are cube scrambles.
    class CubeScrambles
      # Input sampler where the input items are cube scrambles.
      class InputSampler
        SCRAMBLE_LENGTH = 25

        def initialize(mode)
          raise ArgumentError unless mode.cube_size == 3

          @scrambler = CubeScrambler.new
          @cube_state = mode.solved_cube_state
        end

        def random_item(_cached_inputs = [])
          scramble = @scrambler.random_algorithm(SCRAMBLE_LENGTH)
          InputItem.new(Scramble.new(scramble), scramble.apply_to_dupped(@cube_state))
        end
      end

      def initialize(mode)
        @mode = mode
      end

      def hinter(*)
        @hinter ||= NoHinter.new({})
      end

      def input_sampler
        InputSampler.new(@mode)
      end

      def input_items
        nil
      end
    end
  end
end
