# frozen_string_literal: true

require 'cube_trainer/training/abstract_scorer'

module CubeTrainer
  module Training
    # Scorer that assigns an exponentially growing score based on the recent badness that
    # allows us to strongly prefer bad items.
    class BadnessScorer < AbstractScorer
      def extra_info(input_item)
        "badness average #{@result_history.badness_average(input_item).round(2)}"
      end

      # Actual repetition boundary that is adjusted if the number of items is small.
      def repetition_boundary
        [@config[:repetition_boundary], @config[:num_items] / 2].min
      end

      # Adjusts a badness score in order to punish overly fast repetition, even for high badness.
      def repetition_adjusted_score(index, badness_score)
        !index.nil? && index < repetition_boundary ? 0 : badness_score
      end

      # Computes an exponentially growing score based on the given badness that
      # allows us to strongly prefer bad items.
      def score(input_item)
        bad_badness = (@result_history.badness_average(input_item) - @config[:goal_badness]) /
                      @config[:goal_badness]
        return 0 if bad_badness.zero?

        score = @config[:badness_base]**bad_badness
        index = @result_history.items_since_last_occurrence(input_item)
        repetition_adjusted_score(index, score)
      end

      def color_symbol
        :red
      end
    end
  end
end
