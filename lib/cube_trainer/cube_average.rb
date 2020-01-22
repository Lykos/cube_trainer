module CubeTrainer

  # Helper class to compute a rolling average of n as we know it from the cubing world.
  class CubeAverage
    # n is the number of items that are kept in the rolling average and initial_average is used as the average if we have less than 3 items.
    def initialize(n, initial_average)
      raise unless n.is_a?(Integer)
      raise if n < 3
      @n = n
      @values = []
      @average = initial_average
    end
  
    attr_reader :average
  
    def compute_average(array)
      array.reduce(:+) * 1.0 / array.length
    end
  
    def push(value)
      was_saturated = saturated?
      @values.push(value)
      if was_saturated
        @values.shift
      end
      average_part = if @values.length >= 3
                       removed_items = (@values.length * 0.05).ceil
                       @values.sort[removed_items...-removed_items]
                     else
                       @values
                     end
      @average = compute_average(average_part)
    end
  
    def saturated?
      raise if @values.length > @n
      @values.length == @n
    end
  end

end
