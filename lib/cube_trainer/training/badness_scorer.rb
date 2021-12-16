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

      # Used to punish overly fast repetition, even for high badness.
      def too_recently?(input_item)
        @result_history
          .last_case_keys(repetition_boundary)
          .include?(input_item.case_key)
      end

      # Computes an exponentially growing score based on the given badness that
      # allows us to strongly prefer bad items.
      def score(input_item)
        return 0 if too_recently?(input_item)

        bad_badness = (@result_history.badness_average(input_item) - @config[:goal_badness]) /
                      @config[:goal_badness]
        return 0 unless bad_badness.positive?

        @config[:badness_base]**bad_badness
      end

      def color_symbol
        :red
      end
    end
  end
end
