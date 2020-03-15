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
        need_repeat = @result_history.hinted_last_training_day?(input_item) &&
                      !@result_history.occurred_today?(input_item)
        need_repeat ? 1 : 0
      end

      def color_symbol
        :light_red
      end
    end
  end
end
