require 'cube_trainer/training/managed_input_item'
require 'cube_trainer/training/sampler'

module CubeTrainer
  module Training
    # Abstract class to create scores for input items.
    class AbstractScorer
      include Utils::StringHelper

      def initialize(config, result_history)
        @config = config
        @result_history = result_history
      end

      def create_adaptive_sampler(items)
        managed_items = items.map { |i| ManagedInputItem.new(self, i) }
        AdaptiveSampler.new(managed_items) { |i| score(i.input_item) }
      end

      def sampling_info(input_item)
        "sampling component: #{tag}; score: #{score(input_item).round(2)}; #{extra_info(input_item)}"
      end

      def tag
        @tag ||= begin
                   class_name = snake_case_class_name(self.class)
                   raise unless class_name.end_with?('_scorer')

                   class_name.gsub(/_scorer$/, '').colorize(color_symbol)
                 end
      end

      def extra_info(input_item)
        raise NotImplementedError          
      end

      def score(input_item)
        raise NotImplementedError
      end

      def color_symbol
        raise NotImplementedError
      end
    end
  end
end
