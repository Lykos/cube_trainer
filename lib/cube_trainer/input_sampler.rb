# frozen_string_literal: true

require 'cube_trainer/input_item'
require 'cube_trainer/native'
require 'cube_trainer/sampler'
require 'cube_trainer/utils/random_helper'
require 'cube_trainer/utils/sampling_helper'

module CubeTrainer
  class InputSampler
    include RandomHelper

    # Minimum score that we always give to each element in order not to screw up our sampling if all weights become 0 or so.
    EPSILON_SCORE = 0.000000001

    # Boundary at which we don't punish repeating the same item again. But note that this will be adjusted in case of a small total number of items.
    REPETITION_BOUNDARY = 4

    # Exponent that is applied to the time since the last occurrence to punish items that haven't been seen in a long time for coverage samples.
    INDEX_EXPONENT = 2

    # Base that is taken to the power of the badness to punish bad samples.
    BADNESS_BASE = 10

    # Number of occurrences that we go back to the past to compute the badness of a given item.
    # Occurrences longer ago have no effect on the sampling any more.
    BADNESS_MEMORY = 5

    # Number of seconds that are equivalent to one failed attempt. (Used for calculating badness)
    FAILED_SECONDS = 60

    # Fractions that will be used for each type of sampling. Note that the actual sampling also depends on whether or not there are actually
    # new items available or whether items have to be repeated.
    SAMPLING_FRACTIONS = {
      # In case there are still completely new items available, this is the fraction of times that such an item will be chosen.
      # Note that completely new items will never be chosen if a relatively new item needs to be repeated.
      new: 0.1,

      # Fraction of the samples that use uniform samples to even occasionally cover easy cases.
      coverage: 0.15,

      # Fraction of samples that are just simply bad samples.
      badness: 0.75
    }.freeze

    TaggedInputItem = Struct.new(:tag, :input_item)

    # `items` are the items from which we get samples. They have to be an array of InputItem. But the representation inside InputItem can be anything.
    # `results_model` is a helper object that retrieves results to get historic scores.
    # `new_item_bounary` is the number of repetitions at which we stop considering an item a "new item" that needs to be repeated occasionally.
    def initialize(items, results_model, goal_badness = 1.0, verbose = false, repeat_item_boundary = 11)
      raise ArgumentError unless items.is_a?(Array)
      unless items.all? { |e| e.is_a?(InputItem) }
        raise ArgumentError, "Invalid items #{items.inspect}."
      end
      raise unless results_model.respond_to?(:results)
      raise unless goal_badness.is_a?(Float)

      @items = items
      @results_model = results_model
      @goal_badness = goal_badness
      @results_model.add_result_listener(self)
      @verbose = verbose
      @repeat_item_boundary = repeat_item_boundary
      repeat_sampler = create_adaptive_sampler(:repeat)
      combined_sampler = CombinedSampler.new([create_adaptive_subsampler(:new), create_adaptive_subsampler(:badness), create_adaptive_subsampler(:coverage)])
      @sampler = PrioritizedSampler.new([repeat_sampler, combined_sampler])
      reset
    end

    def sampling_tag_score_method(tag)
      m = method((tag.to_s + '_score').to_sym)
      ->(tagged_item) { m.call(tagged_item.input_item) }
    end

    def create_adaptive_sampler(tag)
      tagged_items = @items.map { |i| TaggedInputItem.new(tag, i) }
      AdaptiveSampler.new(tagged_items, sampling_tag_score_method(tag))
    end

    def create_adaptive_subsampler(tag)
      sampler = create_adaptive_sampler(tag)
      fraction = SAMPLING_FRACTIONS[tag] || (raise ArgumentError)
      CombinedSampler::SubSampler.new(sampler, fraction)
    end

    attr_reader :items

    # Reset caches and incremental state, recompute everything from scratch.
    def reset
      @current_occurrence_index = 0
      @occurrence_indices = {}
      @repetition_indices = {}
      @badness_histories = {}
      @badness_histories.default_proc = proc { |h, k| h[k] = Native::CubeAverage.new(BADNESS_MEMORY, EPSILON_SCORE) }
      @occurrences = {}
      @occurrences.default = 0
      @results_model.results.sort_by(&:timestamp).each do |r|
        record_result(r)
      end
    end

    # Called by the results model to notify us about changes on the results.
    # It's not worth it to reimplement fancy logic here, we just recompute everything from scratch.
    def delete_after_time(*_args)
      reset
    end

    # Called by the results model to notify us about changes on the results.
    # It's not worth it to reimplement fancy logic here, we just recompute everything from scratch.
    def replace_word(*_args)
      reset
    end

    # Badness for the given result.
    def result_badness(result)
      result.time_s + FAILED_SECONDS * result.failed_attempts
    end

    # Returns how many items have occurred since the last occurrence of this item (0 if it was the last picked item).
    def items_since_last_occurrence(item)
      occ = @occurrence_indices[item.representation]
      return nil if occ.nil?

      @current_occurrence_index - occ
    end

    # Insert a new result.
    def record_result(result)
      repr = result.input_representation
      @badness_histories[repr].push(result_badness(result))
      @current_occurrence_index += 1
      @occurrence_indices[repr] = @current_occurrence_index
      @occurrences[repr] += 1
    end

    # Actual repetition boundary that is adjusted if the number of items is small.
    def repetition_boundary
      [REPETITION_BOUNDARY, @items.length / 2].min
    end

    # Adjusts a badness score in order to punish overly fast repetition, even for high badness.
    def repetition_adjusted_score(index, badness_score)
      if !index.nil? && index < repetition_boundary
        EPSILON_SCORE
      else
        badness_score
      end
    end

    # A score that prefers items that haven't been shown in a while.
    # We use this score only occasionally (see COVERAGE_FRACTION).
    def coverage_score(item)
      index = items_since_last_occurrence(item)
      return EPSILON_SCORE if index.nil?

      [index**INDEX_EXPONENT, EPSILON_SCORE].max
    end

    def badness_average(item)
      @badness_histories[item.representation].average
    end

    # Computes an exponentially growing score based on the given badness that
    # allows us to strongly prefer bad items.
    def badness_score(item)
      score = BADNESS_BASE**(badness_average(item) - @goal_badness)
      index = items_since_last_occurrence(item)
      [repetition_adjusted_score(index, score), EPSILON_SCORE].max
    end

    # After how many other items should this item be repeated.
    def repetition_index(occ)
      @repetition_indices[occ] ||= begin
                                     rep_index = 2**occ
                                     # Do a bit of random distortion to avoid completely mechanic repetition.
                                     distorted_rep_index = distort(rep_index, 0.2)
                                     # At least 1 other item should always come in between.
                                     [distorted_rep_index.to_i, 1].max
                                   end
    end

    def occurrences(item)
      @occurrences[item.representation]
    end

    # Score for items that are either completely new
    # For all other items, it's 0.
    def new_score(item)
      occurrences(item) == 0 ? 1 : 0
    end

    # Score for items that have occored at least once and have occurred less than `@repeat_item_boundary` times.
    def repeat_score(item)
      occ = occurrences(item)
      if occ == 0 || occ >= @repeat_item_boundary
        # No repetitions necessary any more.
        return 0
      end

      # When the item is completely new, repeat often, then less and less often, but also
      # adjust to the total number of items.
      rep_index = repetition_index(occ)
      index = items_since_last_occurrence(item)
      raise 'Not completely new item has no index.' if index.nil?

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

    def random_item
      tagged_sample = @sampler.random_item
      item = tagged_sample.input_item
      if @verbose
        tag = tagged_sample.tag
        score = sampling_tag_score_method(tag).call(tagged_sample)
        puts "sampling tag: #{tag}; score: #{score}; items since last occurrence #{items_since_last_occurrence(item)}; occurrences: #{occurrences(item)}"
      end
      item
    end
  end

  class RandomSampler
    def initialize(items)
      @items = items
    end

    attr_reader :items

    def random_item
      @items.sample
    end
  end
end
