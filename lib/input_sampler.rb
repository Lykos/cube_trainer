require 'sampling_helper'
require 'cube_average'

class InputSampler

  include SamplingHelper

  # Minimum score that we always give to each element in order not to screw up our sampling if all weights become 0 or so.
  EPSILON_SCORE = 0.000000001

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
  BADNESS_MEMORY = 5

  # Number of repetitions at which we stop considering an item a "new item" that needs to be repeated occasionally.
  NEW_ITEM_BOUNDARY = 8

  # Number of seconds that are equivalent to one failed attempt. (Used for calculating badness)
  FAILED_SECONDS = 60

  # In case there are still completely new items available, this is the fraction of times that such an item will be chosen.
  # Note that completely new items will never be chosen if a relatively new item needs to be repeated.
  COMPLETELY_NEW_ITEMS_FRACTION = 0.4

  # In case there are still relatively new items that need to be repeated available, this is the fraction of times that such an item will be chosen.
  REPEAT_NEW_ITEMS_FRACTION = 0.8

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
    @badness_histories = {}
    @badness_histories.default_proc = proc { |h, k| h[k] = CubeAverage.new(BADNESS_MEMORY, EPSILON_SCORE) }
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
    occ = @occurrence_indices[item]
    return nil if occ.nil?
    @current_occurrence_index - occ
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
  def repetition_adjusted_score(index, badness_score)
    if !index.nil? && index < repetition_boundary && badness_score > Math::E
      # This starts out as e and grows exponentially until it reaches the
      # badness_score at index == REPETITION_BOUNDARY.
      Math.exp(Math.log(badness_score) * (index + 1) / (repetition_boundary + 1))
    else
      badness_score
    end
  end

  # A score that prefers items that haven't been shown in a while.
  # We use this score only occasionally (see COVERAGE_FRACTION).
  def coverage_score(item)
    index = items_since_last_occurrence(item)
    return EPSILON_SCORE if index.nil?
    [index ** INDEX_EXPONENT, EPSILON_SCORE].max
  end

  # Computes an exponentially growing score based on the given badness that
  # allows us to strongly prefer bad items.
  def badness_score(item)
    score = BADNESS_BASE ** (@badness_histories[item].average - @goal_badness)
    index = items_since_last_occurrence(item)
    [repetition_adjusted_score(index, score), EPSILON_SCORE].max
  end

  # Distort the given value randomly by up to the given factor.
  def distort(value, factor)
    raise unless factor > 0 && factor < 1
    value * (1 - factor) + (factor * 2 * value * rand)
  end

  # After how many other items should this item be repeated.
  def repetition_index(occ)
    rep_index = 2 ** occ
    # Do a bit of random distortion to avoid completely mechanic repetition.
    distorted_rep_index = distort(rep_index, 0.2)
    # At least 1 other item should always come in between.
    [distorted_rep_index.to_i, 1].max
  end

  # Score for items that are either completely new or have occurred less than NEW_ITEM_BOUNDARY times.
  # For all other items, it's 0.
  def new_item_score(item)
    occ = @occurrences[item]
    if occ >= NEW_ITEM_BOUNDARY
      return 0
    elsif occ == 0
      # Items that have never been seen get a positive score, but less than items that need
      # to be repeated urgently.
      return 1
    end
    # When the item is completely new, repeat often, then less and less often, but also
    # adjust to the total number of items.
    rep_index = repetition_index(occ)
    index = items_since_last_occurrence(item)
    raise "Not completely new item has no index." if index.nil?
    if index >= rep_index
      if index < [rep_index * 1.5, rep_index + 10].max
        # The sweet spot to repeat items is kind of close to the desired repetition index.
        3
      else
        # If we reach this branch, something went wrong and we didn't manage to repeat
        # this item in time. Probably we have too many items that we are trying to repeat,
        # so we better give up on this one s.t. we can handle the others better.
        2 + 1.0 / index
      end
    else
      0
    end
  end

  # Decide randomly whether we should do a coverage sample. If not, we should do a badness sample.
  def do_coverage_sample
    rand(0) < COVERAGE_FRACTION
  end

  # Decide randomly whether we should handle a new item, i.e. a completely new or a relatively new
  # one that needs to be repeated.
  def do_new_item(new_items_score)
    if new_items_score == 1
      return rand(0) < COMPLETELY_NEW_ITEMS_FRACTION
    else
      return rand(0) < REPEAT_NEW_ITEMS_FRACTION
    end
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
      elsif score == new_items_score && score > 0
        new_items.push(item)
      end
    end
    # If we have a new item that has to be shown, show it.
    if new_items && do_new_item(new_items_score)
      s = new_items.sample
      if new_items_score == 1
        puts "Completely new item!"
      else
        puts "Relatively item sample; Score: #{new_items_score}; items_since_last_occurrence #{items_since_last_occurrence(s)}; occurrences: #{@occurrences[s]}"
      end
      s
    else
      if do_coverage_sample
        s = sample_by (@items) { |s| coverage_score(s) }
        puts "Coverage sample; Score: #{coverage_score(s)}; Badness avg: #{@badness_histories[s].average}; items_since_last_occurrence #{items_since_last_occurrence(s)}; occurrences: #{@occurrences[s]}"
        s
      else
        s = sample_by(@items) { |s| badness_score(s) }
        puts "Badness sample; Score: #{badness_score(s)}; Badness avg #{@badness_histories[s].average}; occurrences: #{@occurrences[s]}"
        s
      end
    end
  end

end
