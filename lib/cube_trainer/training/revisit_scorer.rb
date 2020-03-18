# frozen_string_literal: true

require 'cube_trainer/training/abstract_revisit_scorer'

module CubeTrainer
  module Training
    # A scorer that assigns scores for items that should be repeated on a training day according
    # to exponential backoff. I.e. items that are relatively new by number of training days where
    # they occurred, but not completely new and the right amount of time has passed since the last
    # occurrence.
    class RevisitScorer < AbstractRevisitScorer
      def extra_info(input_item)
        "occurrence days: #{relevant_occurrence_days(input_item)}"
      end

      def relevant_occurrence_days(input_item)
        # Subtract one because the first occurrence doesn't matter.
        @result_history.occurrence_days(input_item) - 1
      end

      # Revisit is necessary for items that have occurred at least once and have occurred less
      # than `@config[:repeat_new_item_days_boundary]` times.
      def revisit_necessary?(input_item)
        occ_days = @result_history.occurrence_days(input_item)
        occ_days.positive? && occ_days < @config[:revisit_new_item_days_boundary]
      end

      def color_symbol
        :light_green
      end
    end
  end
end
