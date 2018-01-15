module CubeTrainer
  module MathHelper
    def round_to_nice(number)
      divisor = 10.0 ** Math.log(number, 10).floor
      digit = (number / divisor).to_i
      raise unless digit >= 1 && digit < 10
      nice_digit = if digit >= 5 then 5 elsif digit >= 2 then 2 else 1 end
      result = nice_digit * divisor
      puts "round_to_nice #{number} #{divisor} #{digit} #{nice_digit} #{result}"
      result
    end
  end
end
