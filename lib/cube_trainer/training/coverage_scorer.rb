# frozen_string_literal: true

require 'cube_trainer/training/abstract_scorer'

module CubeTrainer
  module Training
    # Abstract class for a scorer that prefers items that haven't been shown in a while.
    class AbstractCoverageScorer < AbstractScorer
      def extra_info(input_item)
        "items since last occurrence #{@result_history.items_since_last_occurrence(input_item)}" \
        "days since last occurrence #{@result_history.last_occurrence_days_ago(input_item)}"
      end

      def score(input_item)
        long_ago_metric = long_ago_metric(input_item)
        return 0 if long_ago_metric.nil? || long_ago_metric.zero?

        long_ago_metric**@config[exponent_config_key]
      end

      def color_symbol
        :yellow
      end
    end

    # A scorer that prefers items that haven't been shown in a while, i.e. with lots of items in
    # between.
    class CoverageScorer < AbstractCoverageScorer
      def long_ago_metric(input_item)
        @result_history.items_since_last_occurrence(input_item)
      end

      def exponent_config_key
        :index_exponent
      end
    end

    # A scorer that prefers items that haven't been shown in a lot of training days.
    class DaysCoverageScorer < AbstractCoverageScorer
      def long_ago_metric(input_item)
        @result_history.last_occurrence_days_ago(input_item)
      end

      def exponent_config_key
        :days_ago_exponent
      end
    end
  end
end
