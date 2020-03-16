# frozen_string_literal: true

module CubeTrainer
  module Utils
    # A few time related helper methods.
    module TimeHelper
      SECONDS_PER_DAY = 24 * 60 * 60

      def days_between(left, right)
        ((right - left) / SECONDS_PER_DAY).floor
      end
    end
  end
end
