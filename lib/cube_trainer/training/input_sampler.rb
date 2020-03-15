# frozen_string_literal: true

require 'colorize'
require 'cube_trainer/native'
require 'cube_trainer/training/input_item'
require 'cube_trainer/training/sampler'
require 'cube_trainer/utils/random_helper'
require 'cube_trainer/utils/string_helper'

module CubeTrainer
  module Training
    # An input sampler that tries to adaptively sample items that are useful inputs for the learner.
    class InputSampler
      include Utils::RandomHelper

      # Minimum score that we always give to each element in order not to screw up our sampling if
      # all weights become 0 or so.
      EPSILON_SCORE = 0.000000001

      # Boundary at which we don't punish repeating the same item again. But note that this will be
      # adjusted in case of a small total number of items.
      REPETITION_BOUNDARY = 4

      # Exponent that is applied to the time since the last occurrence to punish items that haven't
      # been seen in a long time for coverage samples.
      INDEX_EXPONENT = 2

      # Base that is taken to the power of the badness to punish bad samples.
      BADNESS_BASE = 10

      # Number of occurrences that we go back to the past to compute the badness of a given item.
      # Occurrences longer ago have no effect on the sampling any more.
      BADNESS_MEMORY = 5

      # Number of seconds that are equivalent to one failed attempt. (Used for calculating badness)
      FAILED_SECONDS = 60

      # Fractions that will be used for each type of sampling. Note that the actual sampling also
      # depends on whether or not there are actually new items available or whether items have to
      # be repeated.
      SAMPLING_FRACTIONS = {
        # In case there are still completely new items available, this is the fraction of times
        # that such an item will be chosen.
        # Note that completely new items will never be chosen if a relatively new item needs to be
        # repeated.
        new: 0.1,

        # Fraction of the samples that use uniform samples to even occasionally cover easy cases.
        coverage: 0.15,

        # Fraction of samples that are just simply bad samples.
        badness: 0.75
      }.freeze

      COLOR_SYMBOLS = {
        new: :green,
        repeat: :light_green,
        coverage: :yellow,
        badness: :red,
      }.freeze

      ManagedInputItem = Struct.new(:manager, :input_item) do
        def sampling_info
          manager.sampling_info(input_item)
        end
      end


      # `items` are the items from which we get samples. They have to be an array of InputItem.
      #         But the representation inside InputItem can be anything.
      # `results_model` is a helper object that retrieves results to get historic scores.
      # `repeat_item_bounary` is the number of repetitions at which we stop considering an item a
      #                       "new item" that needs to be repeated occasionally.
      def initialize(
        items,
        results_model,
        goal_badness = 1.0,
        verbose = false,
        repeat_item_boundary = 11
      )
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
        @sampler = create_sampler
        reset
      end

      class SamplingComponent
        include Utils::StringHelper

        def initialize(input_sampler)
          @input_sampler = input_sampler
        end

        def create_adaptive_sampler
          managed_items = @input_sampler.items.map { |i| ManagedInputItem.new(self, i) }
          AdaptiveSampler.new(managed_items) { |i| score(i.input_item) }
        end

        def sampling_info(input_item)
          "sampling component: #{tag}; score: #{score(input_item).round(2)}; #{extra_info(input_item)}"
        end

        def tag
          snake_case_class_name(self.class).colorize(color_symbol)
        end

        def extra_info(input_item)
          raise NotImplementedError          
        end

        def score(input_item)
          raise NotImplementedError
        end

        def color_symbol
          raise NotImplementedError
        end
      end

      class Repeat < SamplingComponent
        def extra_info(input_item)
          "occurrences #{@input_sampler.occurrences(input_item)}"
        end

        def score(input_item)
          @input_sampler.repeat_score(input_item)
        end

        def color_symbol
          :light_green
        end
      end

      class New < SamplingComponent
        def extra_info(input_item)
          "occurrences #{@input_sampler.occurrences(input_item)}"
        end

        def score(input_item)
          @input_sampler.new_score(input_item)
        end

        def color_symbol
          :green
        end
      end

      class Badness < SamplingComponent
        def extra_info(input_item)
          "badness average #{@input_sampler.badness_average(input_item).round(2)}"
        end

        def score(input_item)
          @input_sampler.badness_score(input_item)
        end

        def color_symbol
          :light_green
        end
      end

      class Coverage < SamplingComponent
        def extra_info(input_item)
          "items since last occurrence #{@input_sampler.items_since_last_occurrence(input_item)}"
        end

        def score(input_item)
          @input_sampler.coverage_score(input_item)
        end

        def color_symbol
          :yellow
        end
      end

      def create_sampler
        repeat_sampler = Repeat.new(self).create_adaptive_sampler
        combined_sampler = CombinedSampler.new(
          [
            create_adaptive_subsampler(New, SAMPLING_FRACTIONS[:new]),
            create_adaptive_subsampler(Badness, SAMPLING_FRACTIONS[:badness]),
            create_adaptive_subsampler(Coverage, SAMPLING_FRACTIONS[:coverage]),
          ]
        )
        PrioritizedSampler.new([repeat_sampler, combined_sampler])
      end

      def create_adaptive_subsampler(sampling_component_class, sampling_fraction)
        raise ArgumentError unless sampling_fraction

        sampler = sampling_component_class.new(self).create_adaptive_sampler
        CombinedSampler::SubSampler.new(sampler, sampling_fraction)
      end

      attr_reader :items

      def new_cube_average
        Native::CubeAverage.new(BADNESS_MEMORY, EPSILON_SCORE)
      end

      # Reset caches and incremental state, recompute everything from scratch.
      def reset
        @current_occurrence_index = 0
        @occurrence_indices = {}
        @repetition_indices = {}
        @badness_histories = {}
        @badness_histories.default_proc = ->(h, k) { h[k] = new_cube_average }
        @occurrences = {}
        @occurrences.default = 0
        @results_model.results.sort_by(&:timestamp).each do |r|
          record_result(r)
        end
      end

      # Called by the results model to notify us about changes on the results.
      # It's not worth it to reimplement fancy logic here, we just recompute everything from
      # scratch.
      def delete_after_time(*_args)
        reset
      end

      # Called by the results model to notify us about changes on the results.
      # It's not worth it to reimplement fancy logic here, we just recompute everything from
      # scratch.
      def replace_word(*_args)
        reset
      end

      # Badness for the given result.
      def result_badness(result)
        result.time_s + FAILED_SECONDS * result.failed_attempts
      end

      # Returns how many items have occurred since the last occurrence of this item
      # (0 if it was the last picked item).
      def items_since_last_occurrence(item)
        occ = @occurrence_indices[item.representation]
        return if occ.nil?

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
        @repetition_indices[occ] ||=
          begin
            rep_index = 2**occ
            # Do a bit of random distortion to avoid completely
            # mechanic repetition.
            distorted_rep_index = distort(rep_index, 0.2)
            # At least 1 other item should always come in between.
            [distorted_rep_index.to_i, 1].max # rubocop:disable Lint/NumberConversion
          end
      end

      def occurrences(item)
        @occurrences[item.representation]
      end

      # Score for items that are either completely new
      # For all other items, it's 0.
      def new_score(item)
        occurrences(item).zero? ? 1 : 0
      end

      def rep_index_score(index, rep_index)
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

      # Score for items that have occored at least once and have occurred less
      # than `@repeat_item_boundary` times.
      def repeat_score(item)
        occ = occurrences(item)
        # No repetitions necessary (any more).
        return 0 if occ.zero? || occ >= @repeat_item_boundary

        # When the item is completely new, repeat often, then less and less often, but also
        # adjust to the total number of items.
        rep_index = repetition_index(occ)
        index = items_since_last_occurrence(item)
        raise 'Not completely new item has no index.' if index.nil?

        rep_index_score(index, rep_index)
      end

      def random_item
        managed_sample = @sampler.random_item
        item = managed_sample.input_item
        puts managed_sample.sampling_info if @verbose
        item
      end
    end

    # A random input sampler that doesn't do anything special or smart.
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
end
