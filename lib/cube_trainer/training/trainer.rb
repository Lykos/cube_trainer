# frozen_string_literal: true

module CubeTrainer
  module Training
    # Class that gives random inputs to a learner class and measures and records how well the
    # learner performs.
    class Trainer
      def initialize(learner, results_model, generator)
        @learner = learner
        @results_model = results_model
        @generator = generator
      end

      def one_iteration
        input = @generator.random_item
        timestamp = Time.now
        partial_result = @learner.execute(input)
        @results_model.record_result(timestamp, partial_result, input.representation)
      end

      def run
        loop do
          one_iteration
        end
      end
    end
  end
end
