# frozen_string_literal: true

require 'cube_trainer/training/abstract_scorer'

module CubeTrainer
  module Training
    # A scorer that assigns a non-zero score only iff an item is new.
    class NewScorer < AbstractScorer
      def extra_info(input_item)
        "occurrences #{@result_history.occurrences(input_item)}"
      end

      # Score for items that are completely new.
      # For all other items, it's 0.
      def score(input_item)
        @result_history.occurrences(input_item).zero? ? 1 : 0
      end

      def color_symbol
        :green
      end
    end
  end
end
