# frozen_string_literal: true

module CubeTrainer
  module Utils
    module MathHelper
      def next_lower_nice_digit(digit)
        if digit >= 5
          5
        elsif digit >= 2
          2
        else
          1
        end
      end

      def floor_to_nice(number)
        divisor = 10.0**Math.log(number, 10).floor
        first_digit = (number / divisor).to_i
        raise unless first_digit >= 1 && first_digit < 10

        next_lower_nice_digit(first_digit) * divisor
      end

      def floor_to_step(number, step)
        step * (number / step).floor
      end
    end
  end
end
