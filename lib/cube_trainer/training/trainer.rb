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
        result_params = @learner.execute(input_item)
        Result.create!(result_params)
      end

      def run
        loop do
          one_iteration
        end
      end
    end
  end
end
