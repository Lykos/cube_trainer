# frozen_string_literal: true

require 'cube_trainer/training/abstract_scorer'

module CubeTrainer
  module Training
    # A scorer that assigns scores for items that should be repeated on a training day according
    # to exponential backoff.
    class AbstractRevisitScorer < AbstractScorer
      def score(input_item)
        # No repetitions necessary (any more).
        return 0 if @result_history.occurred_today?(input_item)
        return 0 unless revisit_necessary?(input_item)

        # When the item is completely new, repeat often, then less and less often.
        repeat_after_days = 2**relevant_occurrence_days(input_item)
        repeat_days_ago = @result_history.last_occurrence_days_ago(input_item) - repeat_after_days
        [repeat_days_ago + 1, 0].max
      end

      def revisit_necessary?(_input_item)
        raise NotImplementedError
      end

      def relevant_occurrence_days(_input_item)
        raise NotImplementedError
      end
    end
  end
end
