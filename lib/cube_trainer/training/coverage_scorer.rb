require 'cube_trainer/training/abstract_scorer'

module CubeTrainer
  module Training
    # A scorer that prefers items that haven't been shown in a while.
    class CoverageScorer < AbstractScorer
      def extra_info(input_item)
        "items since last occurrence #{@result_history.items_since_last_occurrence(input_item)}"
      end

      # A score that prefers items that haven't been shown in a while.
      def score(input_item)
        index = @result_history.items_since_last_occurrence(input_item)
        return @config[:epsilon_score] if index.nil?

        [index**@config[:index_exponent], @config[:epsilon_score]].max
      end

      def color_symbol
        :yellow
      end
    end
  end
end
