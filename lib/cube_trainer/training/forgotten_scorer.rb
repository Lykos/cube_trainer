# frozen_string_literal: true

require 'cube_trainer/training/abstract_scorer'

module CubeTrainer
  module Training
    # A scorer that prefers items that the human forgot on the last training day.
    class ForgottenScorer < AbstractScorer
      def extra_info(input_item); end

      # A score that prefers items that haven't been shown in a while.
      def score(input_item)
        @result_history.hinted_last_training_day?(input_item) ? 1 : 0
      end

      def color_symbol
        :yellow
      end
    end
  end
end
