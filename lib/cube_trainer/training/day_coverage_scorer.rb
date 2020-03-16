# frozen_string_literal: true

require 'cube_trainer/training/abstract_scorer'

module CubeTrainer
  module Training
    # A scorer that prefers items that haven't been shown in a lot of training days.
    class DaysCoverageScorer < AbstractScorer
      def extra_info(input_item)
        "days since last occurrence #{@result_history.last_occurrence_days_ago(input_item)}"
      end

      # A score that prefers items that haven't been shown in a lot of training days.
      def score(input_item)
        days_ago = @result_history.last_occurrence_days_ago(input_item)
        return @config[:epsilon_score] if days_ago.nil?

        [days_ago**@config[:days_ago_exponent], @config[:epsilon_score]].max
      end

      def color_symbol
        :yellow
      end
    end
  end
end
