# frozen_string_literal: true

module CubeTrainer
  module Training
    # Class that gives random inputs to a learner class and measures and records how well the
    # learner performs.
    class Trainer
      def initialize(learner, mode, generator)
        @learner = learner
        @mode = mode
        @generator = generator
      end

      def one_iteration
        input_item = @generator.random_item
        input = @mode.inputs.new(input_representation: input_item.representation)
        input.save!
        partial_result = @learner.execute(input_item)
        Result.from_input_and_partial(input, partial_result).save!
      end

      def run
        loop do
          one_iteration
        end
      end
    end
  end
end
