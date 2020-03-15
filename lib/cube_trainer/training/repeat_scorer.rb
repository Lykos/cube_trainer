require 'cube_trainer/training/abstract_scorer'

module CubeTrainer
  module Training
    # A scorer that assigns scores for items that should be repeated according to exponential
    # backoff. I.e. items that are relatively new, but not completely new and the right amount
    # of time has passed since the last occurrence.
    class RepeatScorer < AbstractScorer
      def extra_info(input_item)
        "occurrences #{@result_history.occurrences(input_item)}"
      end

      def rep_index_score(index, rep_index)
        if index >= rep_index
          if index < [rep_index * 1.5, rep_index + 10].max
            # The sweet spot to repeat items is kind of close to the desired repetition index.
            3
          else
            # If we reach this branch, something went wrong and we didn't manage to repeat
            # this item in time. Probably we have too many items that we are trying to repeat,
            # so we better give up on this one s.t. we can handle the others better.
            2 + 1.0 / index
          end
        else
          0
        end
      end

      # Score for items that have occurred at least once and have occurred less
      # than `@config[:repeat_item_boundary]` times.
      def score(input_item)
        occ = @result_history.occurrences(input_item)
        # No repetitions necessary (any more).
        return 0 if occ.zero? || occ >= @config[:repeat_item_boundary]

        # When the item is completely new, repeat often, then less and less often, but also
        # adjust to the total number of items.
        rep_index = @result_history.repetition_index(occ)
        index = @result_history.items_since_last_occurrence(input_item)
        raise 'Not completely new item has no index.' if index.nil?

        rep_index_score(index, rep_index)
      end

      def color_symbol
        :light_green
      end
    end
  end
end
