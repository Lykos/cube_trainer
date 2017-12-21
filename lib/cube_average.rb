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

  def push(value)
    was_saturated = saturated?
    @values.push(value)
    if was_saturated
      @values.shift
    end
    if @values.length >= 3
      removal_part = (@values.length * 0.05).ceil
      average_part = @values.sort[removal_part..@values.length - removal_part]
      @average = average_part.reduce(:+) / average_part.length
    end
    nil
  end

  def saturated?
    raise if @values.length > @n
    @values.length == @n
  end
end
