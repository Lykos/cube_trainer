# frozen_string_literal: true

require 'cube_trainer/training/abstract_scorer'
require 'cube_trainer/utils/random_helper'

module CubeTrainer
  module Training
    # A scorer that assigns scores for items that should be repeated according to exponential
    # backoff. I.e. items that are relatively new by number of occurrences, but not completely new
    # and the right amount of items have occurred since the last occurrence.
    class RepeatScorer < AbstractScorer
      include Utils::RandomHelper

      def initialize(config, result_model)
        super
        @repetition_indices = {}
      end

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
            2 + (1.0 / index)
          end
        else
          0
        end
      end

      # Score for items that have occurred at least once and have occurred less
      # than `@config[:repeat_new_item_times_boundary]` times.
      def score(input_item)
        occ = @result_history.occurrences(input_item)
        # No repetitions necessary (any more).
        return 0 if occ.zero? || occ >= @config[:repeat_new_item_times_boundary]

        # When the item is completely new, repeat often, then less and less often, but also
        # adjust to the total number of items.
        rep_index = repetition_index(input_item.representation, occ)

        @result_history.last_items(rep_index).include?(input_item.representation) ? 0 : 1
      end

      # After how many other items should this item be repeated.
      def repetition_index(input_representation, occ)
        @repetition_indices[[input_representation, occ]] ||=
          begin
            rep_index = 2**occ
            # Do a bit of random distortion to avoid completely
            # mechanic repetition.
            distorted_rep_index = distort(rep_index, 0.2)
            # At least 1 other item should always come in between.
            [distorted_rep_index.floor, 1].max
          end
      end

      def color_symbol
        :light_green
      end
    end
  end
end
