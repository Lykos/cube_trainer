# frozen_string_literal: true

module CubeTrainer
  module Utils
    # A few time related helper methods.
    module TimeHelper
      def days_between(left, right)
        days(right - left)
      end

      def time_in_unit(time_s, unit)
        return time_s if time_s.infinite?

        (time_s / unit).floor
      end

      def days(time_s)
        time_in_unit(time_s, 1.day)
      end

      def minutes(time_s)
        time_in_unit(time_s, 1.minute)
      end
    end
  end
end
