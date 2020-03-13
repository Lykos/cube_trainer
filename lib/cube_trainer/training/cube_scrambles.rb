require 'cube_trainer/cube_scrambler'
require 'cube_trainer/training/no_hinter'

module CubeTrainer
  module Training
    class CubeScrambles
      class InputSampler
        SCRAMBLE_LENGTH = 25

        def initialize(color_scheme)
          @scrambler = CubeScrambler.new
          @cube_state = color_scheme.solved_cube_state(3)
        end

        def random_item
          scramble = @scrambler.random_algorithm(SCRAMBLE_LENGTH)
          InputItem.new(scramble, scramble.apply_to_dupped(@cube_state))
        end
      end

      def initialize(options)
        @options = options
      end

      def hinter(*)
        NoHinter.new({})
      end

      def input_sampler(*)
        @input_sampler ||= InputSampler.new(@options.color_scheme)
      end

      def input_items
        nil
      end
    end
  end
end
