module SamplingHelper

  FAILED_SECONDS = 10
  NEWER_WEIGHT = 2
  INDEX_EXPONENT = 2
  HIGH_BADNESS = 10000

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

  def badness(result)
    result.time_s + FAILED_SECONDS * result.failed_attempts
  end

  def badness_sum(badnesses)
    badnesses.reverse.inject(HIGH_BADNESS) do |avg, b|
      (avg + b * NEWER_WEIGHT) / (NEWER_WEIGHT + 1)
    end
  end

  def compute_history_scores(results)
    # badness sum per input
    badnesses = {}
    badnesses.default_proc = proc { |h, k| h[k] = [] }
    earliest_indices = {}
    results.each_with_index do |r, i|
      badnesses[r.input].push(badness(r))
      earliest_indices[r.input] = i unless earliest_indices.has_key?(r.input)
    end
    scores = {}
    results.each_with_index do |r, i|
      badness = badness_sum(badnesses[r.input])
      index = earliest_indices[r.input]
      scores[r.input] = score(badness, index)
    end
    [scores, badnesses, earliest_indices]
  end

  def score(badness, index)
    (badness + 1) * index ** INDEX_EXPONENT
  end

  def random_input(inputs, results)
    seen_input = results.collect { |r| r.input }.uniq
    unseen_input = inputs - seen_input
    unless unseen_input.empty?
      # If not all input has been seen, only choose items that haven't been seen yet
      unseen_input.sample
    else
      history_scores, badnesses, indices = compute_history_scores(results)
      s = sample_by(inputs) { |p| history_scores[p] }
      puts "Score: #{history_scores[s] / 1000000}; badness avg #{badness_sum(badnesses[s])}: ; index: #{indices[s]}; occurrences: #{badnesses[s].length}"
      s
    end
  end

end
