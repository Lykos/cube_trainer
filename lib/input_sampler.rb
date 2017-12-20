require 'sampling_helper'
require 'cube_average'

class InputSampler

  include SamplingHelper

  # Minimum score that we always give to each element in order not to screw up our sampling if all weights become 0 or so.
  EPSILON_SCORE = 0.000000001

  # Factor we multiply the badnesses with for more readable debug output.
  READABILITY_FACTOR = 1000

  # Boundary at which we don't punish repeating the same item again. But note that this will be adjusted in case of a small number of items.
  REPETITION_BOUNDARY = 10

  # Exponent that is applied to the time since the last occurrence to punish items that haven't been seen in a long time for coverage samples.
  INDEX_EXPONENT = 1.2

  # Base that is taken to the power of the badness to punish bad samples.
  BADNESS_BASE = 10

  # Fraction of the samples that use uniform samples to even occasionally cover
  # easy cases.
  COVERAGE_FRACTION = 0.2

  # Number of occurrences that we go back to the past to compute the badness of a given item.
  # Occurrences longer ago have no effect on the sampling any more.
  # Note that as long as some items don't have at least this many occurrences, normal sampling
  # Cannot be done for those items.
  BADNESS_MEMORY = 5

  # Number of seconds that are equivalent to one failed attempt. (Used for calculating badness)
  FAILED_SECONDS = 60

  def initialize(items, results_model, goal_badness=1.0)
    @items = items
    @results_model = results_model
    @goal_badness = goal_badness
    @results_model.add_result_listener(self)
    reset
  end
  
  def reset
    @current_occurrence_index = 0
    @occurrence_indices = {}
    @occurrence_indices.default = 0
    @badness_histories = {}
    @badness_histories.default_proc = proc { |h, k| h[k] = CubeAverage.new(BADNESS_MEMORY) }
    @occurrences = {}
    @occurrences.default = 0
    @results_model.results.sort_by { |r| r.timestamp }.each do |r|
      record_result(r)
    end
  end

  # Called by the results model to notify us about changes on the results.
  # It's not worth it to reimplement fancy logic here, we just recompute everything from scratch.
  def delete_after_time(*args)
    reset    
  end

  # Called by the results model to notify us about changes on the results.
  # It's not worth it to reimplement fancy logic here, we just recompute everything from scratch.
  def replace_word(*args)
    reset
  end

  # Badness for the given result.
  def result_badness(result)
    result.time_s + FAILED_SECONDS * result.failed_attempts
  end

  # Returns how many items have occurred since the last occurrence of this item (0 if it was the last picked item).
  def items_since_last_occurrence(item)
    @current_occurrence_index - @occurrence_indices[item]
  end

  # Insert a new result.
  def record_result(result)
    item = result.input
    @badness_histories[item].push(result_badness(result))
    @current_occurrence_index += 1
    @occurrence_indices[item] = @current_occurrence_index
    @occurrences[item] += 1
  end

  # Actual repetition boundary that is adjusted if the number of items is small.
  def repetition_boundary
    [REPETITION_BOUNDARY, @items.length / 2].min
  end

  # Adjusts a badness score in order to punish overly fast repetition, even for high badness.
  def repetition_adjust_score(index, badness_score)
    if index < repetition_boundary
      # This starts out as EPSILON and grows exponentially until it reaches the
      # badness_score at index == REPETITION_BOUNDARY.
      EPSILON ** (Math.log(badness_score, EPSILON) * (index + 1) / (repetition_boundary + 1))
    else
      badness_score
    end
  end

  # A score that prefers items that haven't been shown in a while.
  # We use this score only occasionally (see COVERAGE_FRACTION).
  def coverage_score(item)
    [items_since_last_occurrence(item) ** INDEX_EXPONENT, EPSILON_SCORE].max
  end

  # Computes an exponentially growing score based on the given badness that
  # allows us to strongly prefer bad items.
  def badness_score(item)
    # If we don't have enough samples to compute the badness average (i.e. it's not saturated),
    # we just choose score epsilon in order to guarantee that our score sum is strictly positive.
    # Note that it can actually happen that we reach this code even if not all items are saturated
    # if the item doesn't need to be repeated because of the `new_item_score`.
    badness = if badness_histories[item].saturated?
                BADNESS_BASE ** (badness_histories[item].average - goal_badness)
              else
                EPSILON
              end
    index = items_since_last_occurrence(item)
    [repetition_adjusted_score(index, badness_score), EPSILON_SCORE].max
  end

  # Score for items that are either completely new or have occurred less than BADNESS_MEMORY times.
  # For all other items, it's 0.
  def new_item_score(item)
    occ = @occurrences[item]
    if occ >= BADNESS_MEMORY
      return 0
    elsif occ == 0
      # Items that have never been seen get a positive score, but less than items that need
      # to be repeated urgently.
      return 1
    end
    # When the item is completely new, repeat often, then less and less often, but also
    # adjust to the total number of items.
    repetition_index = [2 ** occ, @items.length / 2].min
    # Do a random adjustment to avoid overly deterministic repetitions.
    repetition_index = repetition_index / 2 + rand(repetition_index)
    # Now give a score depending on how long a go this item should have been repeated.
    [items_since_last_occurrence(item) - repetition_index, 0].max
  end

  # Decide randonly whether we should do a coverage sample. If not, we should do a badness sample.
  def do_coverage_sample
    rand(0) < COVERAGE_FRACTION
  end

  def random_item
    # First check whether there are any new items that we have to show to the user.
    new_items = nil
    new_items_score = 0
    @items.each do |item|
      score = new_item_score(item)
      if score > new_items_score
        new_items = [item]
        new_items_score = score
      elsif score == new_items_score
        new_items.push(item)
      end
    end
    # If we have a new item that has to be shown, show it.
    if new_items
      s = new_items.sample
      puts "New item sample; Score: #{new_items_score}; occurrences: #{@occurrences[s]}"
      s
    else
      if do_coverage_sample
        s = sample_by (@items) { |p| coverage_score(p) }
        puts "Coverage sample; Score: #{coverage_score(s)}; Badness score: #{badness_score(item)}; items_since_last_occurrence #{items_since_last_occurrence(s)}; occurrences: #{@occurrences[s]}"
        s
      else
        s = sample_by(items) { |p| badness_score(p) }
        puts "Badness sample; Score: #{badness_score(item)}; badness avg #{@badnesses_histories[s].average}; occurrences: #{@occurrences[s]}"
        s
      end
    end
  end

end
