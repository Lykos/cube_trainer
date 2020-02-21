# frozen_string_literal: true

require 'cube_trainer/utils/random_helper'

module CubeTrainer
  module Anki
    # Helper class that returns a backoff in seconds for each iteration.
    # Allows to retry things with exponential backoff.
    class ExponentialBackoff
      include Utils::RandomHelper

      def initialize(_initial_backoff_s = 0.1, max_backoff_s = 5)
        @initial_backoff_s = 1
        @max_backoff_s = max_backoff_s
        @attempts = 0
      end

      def next_backoff_s
        backoff_s =
          if @attempts.zero?
            0
          else
            @initial_backoff_s * distort(1 << @attempts, 0.5)
          end
        @attempts += 1
        backoff_s
      end
    end
  end
end
