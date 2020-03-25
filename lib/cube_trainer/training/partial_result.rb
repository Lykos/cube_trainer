# frozen_string_literal: true

module CubeTrainer
  module Training
    # The part of the result that basically comes from the input of whoever is
    # learning.
    PartialResult =
      Struct.new(:time_s, :failed_attempts, :word, :success, :num_hints) do
        def initialize(time_s, failed_attempts: 0, word: nil, success: true, num_hints: 0)
          super(time_s, failed_attempts, word, success, num_hints)
        end
      end
  end
end
