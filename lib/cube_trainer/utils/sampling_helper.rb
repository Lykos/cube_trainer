# frozen_string_literal: true

module CubeTrainer
  module Utils
    # A few sampling related helper methods.
    module SamplingHelper
      # Draw a random sample from `array` and use `block` to calculate the weight of each item.
      def sample_by(array, random = Random, &block)
        raise ArgumentError, 'Cannot sample empty array.' if array.empty?

        weights = extract_weights(array, &block)
        weight_sum = weights.sum
        raise ArgumentError, "Can't sample for total weight 0.0." if weight_sum == 0.0

        index_by_weight(array, weights, random.rand * weight_sum)
      end

      private

      def extract_weights(array, &block)
        weights = array.map(&block)
        raise TypeError, 'Negative weights are not allowed for sampling.' unless weights.all?(Numeric)
        raise ArgumentError, 'Negative weights are not allowed for sampling.' if weights.any?(&:negative?)

        if weights.any?(&:infinite?)
          weights.map { |a| a.infinite? ? 1 : 0 }
        else
          weights
        end
      end

      def index_by_weight(array, weights, weight)
        prefix_weight = 0.0
        index = 0
        while prefix_weight < weight
          prefix_weight += weights[index]
          index += 1
        end
        array[index - 1]
      end
    end
  end
end
