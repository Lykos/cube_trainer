# frozen_string_literal: true

require 'cube_trainer/training/abstract_revisit_scorer'

module CubeTrainer
  module Training
    # A scorer that prefers items that the human forgot on recent training days.
    class ForgottenScorer < AbstractRevisitScorer
      def extra_info(input_item)
        last_hinted_days_ago = @result_history.last_hinted_days_ago(input_item)
        occ_days_since_last_hint = relevant_occurrence_days(input_item)
        "last_hinted_days_ago: #{last_hinted_days_ago}; occurrence_days_since_last_hint: " \
        "#{occ_days_since_last_hint}"
      end

      def relevant_occurrence_days(input_item)
        @result_history.occurrence_days_since_last_hint(input_item)
      end

      def revisit_necessary?(input_item)
        @result_history.last_hinted_days_ago(input_item) &&
          @result_history.occurrence_days_since_last_hint(item) <
            @config[:repeat_forgotten_item_days_boundary]
      end

      def color_symbol
        :light_red
      end
    end
  end
end
