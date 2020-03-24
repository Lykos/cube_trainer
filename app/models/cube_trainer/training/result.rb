# frozen_string_literal: true

module CubeTrainer
  module Training
    # Result of giving one task to the learner and judging their performance.
    # TODO Migrate from LegacyResult in lib/ to this.
    class Result < ApplicationRecord
    end
  end
end
