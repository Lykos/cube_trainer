module SamplingHelper

  def sample_by(array, &block)
    weights = array.collect(&block)
    weight_sum = weights.reduce(:+)
    number = rand(weight_sum)
    index = 0
    while weights[index] < number
      number -= weights[index]
      index += 1
    end
    array[index]
  end

  def compute_history_scores(results)
    # overall average
    overall_average = results.collect { |r| r.time_s }.inject(0.0, :+)
    # time sum per input
    sums = {}
    sums.default = 0.0
    # occurrences per input
    occurrences = {}
    occurrences.default = 0
    earliest_index = {}
    results.each_with_index do |r, i|
      sums[r.input] += r.time_s
      occurrences[r.input] += 1
      earliest_index[r.input] = i unless earliest_index.has_key?(r.input)
    end
    scores = {}
    results.each_with_index do |r, i|
      average = sums[r.input] / occurrences[r.input]
      badness = average / overall_average
      scores[r.input] = badness * earliest_index[r.input]
    end
    scores
  end

  def random_input(inputs, results)
    seen_input = results.collect { |r| r.input }.uniq
    unseen_input = inputs - seen_input
    unless unseen_input.empty?
      # If not all input has been seen, only choose items that haven't been seen yet
      unseen_input.sample
    else
      history_scores = compute_history_scores
      sample_by(inputs) { |p| history_scores[p] }
    end
  end

end
