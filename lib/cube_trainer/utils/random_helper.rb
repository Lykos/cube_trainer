# frozen_string_literal: true

module CubeTrainer
  module Utils
    # A few randomness related helper methods.
    module RandomHelper
      # Distort the given value randomly by up to the given factor.
      def distort(value, factor)
        raise ArgumentError unless factor.positive? && factor < 1

        value * (1 - factor) + (factor * 2 * value * rand)
      end
    end
  end
end
