# frozen_string_literal: true

require 'cube_trainer/training/abstract_scorer'

module CubeTrainer
  module Training
    # A scorer that prefers items that the human forgot on the last training day.
    class ForgottenScorer < AbstractScorer
      def extra_info(input_item); end

      # A score that prefers items that the user hasn't seen today but forgot
      # on the last time he trained.
      def score(input_item)
        return 0 unless forgotten(input_item)
        repeat_after_days = 2**@result_history.occurrence_days_since_last_hint(item)
        repeat_days_ago = @result_history.last_hinted_days_ago(input_item) - repeat_after_days
        [repeat_days_ago + 1, 0].max
      end

      def forgotten(input_item)
        !@result_history.occurred_today?(input_item) &&
          @result_history.last_hinted_days_ago(input_item) &&
          @result_history.occurrence_days_since_last_hint(item) <
          @config[:repeat_forgotten_item_boundary]
      end

      def color_symbol
        :light_red
      end
    end
  end
end
