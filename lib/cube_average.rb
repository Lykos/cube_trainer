# Helper class to compute a rolling average of n as we know it from the cubing world.
class CubeAverage
  def initialize(n)
    raise unless n.is_a?(Integer)
    raise if n <= 3
    @n = n
    @values = []
  end

  def push(value)
    @average = nil
    was_saturated = saturated?
    @values.push(value)
    if was_saturated
      @values.shift
    end
    if saturated?
      removal_part = (@n * 0.05).ceil
      average_part = @values.sort[removal_part..@n - removal_part]
      @average = average_part.reduce(:+) / (@n - 2 * removal_part)
    end
    nil
  end

  def saturated?
    raise if @values.length > @n
    @values.length == @n
  end

  def average
    raise "Can't compute an ao#{n} with only #{@values.length} items." unless saturated?
    @average
  end
end
