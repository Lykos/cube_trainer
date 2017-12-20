module SamplingHelper
  
  # Draw a random sample from `array` and use `block` to calculate the weight of each item.
  def sample_by(array, &block)
    raise "Cannot sample empty array." if array.empty?
    weights = array.collect(&block)
    raise "Negative weights are not allowed for sampling." if weights.any? { |w| w < 0.0 }
    weight_sum = weights.reduce(:+)
    raise "Can't sample for total weight 0.0." if weight_sum == 0.0
    number = rand(weight_sum)
    index = 0
    while weights[index] < number
      number -= weights[index]
      index += 1
    end
    array[index]
  end

end
