# frozen_string_literal: true

require_relative '../training'
require_relative '../../application_record'

module CubeTrainer
  module Training
    # Result of giving one task to the learner and judging their performance.
    # TODO Migrate from LegacyResult in lib/ to this.
    class Result < ApplicationRecord
      attribute :mode, :symbol
      attribute :input_representation, :input_representation

      def self.from_partial(mode, timestamp, partial_result, input_representation)
        new(
          mode,
          timestamp,
          partial_result.time_s,
          input_representation,
          partial_result.failed_attempts,
          partial_result.word,
          partial_result.success,
          partial_result.num_hints
        )
      end
    end
  end
end
