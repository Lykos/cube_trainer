module SamplingHelper

  NEWER_WEIGHT = 1.2
  INDEX_EXPONENT = 1.2
  READABILITY_FACTOR = 10

  def badness_exponent
    4
  end
  
  def failed_seconds
    10
  end

  def goal_badness
    1.0
  end

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
    result.time_s + failed_seconds * result.failed_attempts
  end

  def badness_sum(badnesses)
    badnesses.reverse.reduce do |avg, b|
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

  # The index term is used to make sure that even if my badness formula is too strong and
  # some items have a chance of 10**-10 to get picked, they eventually get picked again
  # if their index gets too high.
  def index_score(index)
    index ** INDEX_EXPONENT / 100
  end

  def badness_score(badness)
    return 0 if badness < goal_badness
    (badness - goal_badness) ** badness_exponent
  end  

  def score(badness, index)
    badness_score(badness) + index_score(index)
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
      puts "Score: #{history_scores[s] / READABILITY_FACTOR}; badness avg #{badness_sum(badnesses[s])}; badness score: #{badness_score(badness_sum(badnesses[s])) / READABILITY_FACTOR}; index: #{indices[s]}; index_score: #{index_score(indices[s]) / READABILITY_FACTOR}; occurrences: #{badnesses[s].length}"
      s
    end
  end

end
