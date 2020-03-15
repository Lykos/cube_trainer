# frozen_string_literal: true

require 'colorize'
require 'cube_trainer/native'
require 'cube_trainer/training/input_item'
require 'cube_trainer/training/result_history'
require 'cube_trainer/training/sampler'
require 'cube_trainer/utils/random_helper'
require 'cube_trainer/utils/string_helper'

module CubeTrainer
  module Training
    # An input sampler that tries to adaptively sample items that are useful inputs for the learner.
    class InputSampler
      include Utils::RandomHelper

      DEFAULT_CONFIG = {
        # Minimum score that we always give to each element in order not to screw up our sampling if
        # all weights become 0 or so.
        epsilon_score: 0.000000001,

        # Boundary at which we don't punish repeating the same item again. But note that this will
        # be adjusted in case of a small total number of items.
        repetition_boundary: 4,

        # Exponent that is applied to the time since the last occurrence to punish items that
        # haven't been seen in a long time for coverage samples.
        index_exponent: 2,

        # Base that is taken to the power of the badness to punish bad samples.
        badness_base: 10,

        # Number of occurrences that we go back to the past to compute the badness of a given item.
        # Occurrences longer ago have no effect on the sampling any more.
        badness_memory: 5,

        # Number of seconds that are equivalent to one failed attempt. (Used for calculating badness)
        failed_seconds: 60,

        # The badness that we want to reach. If something is below this, we won't practice it much
        # any more.
        goal_badness: 1.0,

        # The number of repetitions at which we stop considering an item a "new item" that needs to
        # be repeated occasionally.
        repeat_item_boundary: 11
      }.freeze


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

      ManagedInputItem = Struct.new(:manager, :input_item) do
        def sampling_info
          manager.sampling_info(input_item)
        end
      end


      # `items` are the items from which we get samples. They have to be an array of InputItem.
      #         But the representation inside InputItem can be anything.
      # `results_model` is a helper object that retrieves results to get historic scores.
      # `repeat_item_boundary` is the number of repetitions at which we stop considering an item a
      #                       "new item" that needs to be repeated occasionally.
      def initialize(
        items,
        results_model,
        goal_badness = nil,
        verbose = false,
        repeat_item_boundary = nil
      )
        raise ArgumentError unless items.is_a?(Array)
        unless items.all? { |e| e.is_a?(InputItem) }
          raise ArgumentError, "Invalid items #{items.inspect}."
        end
        raise unless goal_badness.is_a?(Float)

        @items = items
        @config = DEFAULT_CONFIG.dup
        @config[:num_items] = items.length
        @config[:goal_badness] ||= goal_badness
        @config[:repeat_item_boundary] ||= repeat_item_boundary
        @verbose = verbose
        @result_history = ResultHistory.new(
          results_model,
          epsilon_score: @config[:epsilon_score],
          badness_memory: @config[:badness_memory],
          failed_seconds: @config[:failed_seconds]
        )
        @sampler = create_sampler(results_model)
      end

      class AbstractScorer
        include Utils::StringHelper

        def initialize(config, result_history)
          @config = config
          @result_history = result_history
        end

        def create_adaptive_sampler(items)
          managed_items = items.map { |i| ManagedInputItem.new(self, i) }
          AdaptiveSampler.new(managed_items) { |i| score(i.input_item) }
        end

        def sampling_info(input_item)
          "sampling component: #{tag}; score: #{score(input_item).round(2)}; #{extra_info(input_item)}"
        end

        def tag
          @tag ||= begin
                     class_name = snake_case_class_name(self.class)
                     raise unless class_name.end_with?('_scorer')

                     class_name.gsub(/_scorer$/, '').colorize(color_symbol)
                   end
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

      class RepeatScorer < AbstractScorer
        def extra_info(input_item)
          "occurrences #{@result_history.occurrences(input_item)}"
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

        # Score for items that have occurred at least once and have occurred less
        # than `@repeat_item_boundary` times.
        def score(input_item)
          occ = @result_history.occurrences(input_item)
          # No repetitions necessary (any more).
          return 0 if occ.zero? || occ >= @config[:repeat_item_boundary]

          # When the item is completely new, repeat often, then less and less often, but also
          # adjust to the total number of items.
          rep_index = repetition_index(occ)
          index = @result_history.items_since_last_occurrence(input_item)
          raise 'Not completely new item has no index.' if index.nil?

          rep_index_score(index, rep_index)
        end

        def color_symbol
          :light_green
        end
      end

      class NewScorer < AbstractScorer
        def extra_info(input_item)
          "occurrences #{@result_history.occurrences(input_item)}"
        end

        # Score for items that are completely new.
        # For all other items, it's 0.
        def score(input_item)
          @result_history.occurrences(input_item).zero? ? 1 : 0
        end

        def color_symbol
          :green
        end
      end

      class BadnessScorer < AbstractScorer
        def extra_info(input_item)
          "badness average #{@result_history.badness_average(input_item).round(2)}"
        end

        # Actual repetition boundary that is adjusted if the number of items is small.
        def repetition_boundary
          [@config[:repetition_boundary], @config[:num_items] / 2].min
        end

        # Adjusts a badness score in order to punish overly fast repetition, even for high badness.
        def repetition_adjusted_score(index, badness_score)
          if !index.nil? && index < repetition_boundary
            @config[:epsilon_score]
          else
            badness_score
          end
        end

        # Computes an exponentially growing score based on the given badness that
        # allows us to strongly prefer bad items.
        def score(input_item)
          score = @config[:badness_base]**(@result_history.badness_average(input_item) - @config[:goal_badness])
          index = @result_history.items_since_last_occurrence(input_item)
          [repetition_adjusted_score(index, score), @config[:epsilon_score]].max
        end

        def color_symbol
          :light_green
        end
      end

      class CoverageScorer < AbstractScorer
        def extra_info(input_item)
          "items since last occurrence #{@result_history.items_since_last_occurrence(input_item)}"
        end

        # A score that prefers items that haven't been shown in a while.
        # We use this score only occasionally (see COVERAGE_FRACTION).
        def score(input_item)
          index = @result_history.items_since_last_occurrence(input_item)
          return @config[:epsilon_score] if index.nil?

          [index**@config[:index_exponent], @config[:epsilon_score]].max
        end

        def color_symbol
          :yellow
        end
      end

      def create_sampler(results_model)
        repeat_sampler = create_adaptive_sampler(Repeat)
        combined_sampler = CombinedSampler.new(
          [
            create_adaptive_subsampler(New, SAMPLING_FRACTIONS[:new]),
            create_adaptive_subsampler(Badness, SAMPLING_FRACTIONS[:badness]),
            create_adaptive_subsampler(Coverage, SAMPLING_FRACTIONS[:coverage]),
          ]
        )
        PrioritizedSampler.new([repeat_sampler, combined_sampler])
      end

      def create_adaptive_sampler(scorer_class)
        scorer_class.new(@config, @result_history).create_adaptive_sampler(@items)
      end

      def create_adaptive_subsampler(scorer_class, sampling_fraction)
        raise ArgumentError unless sampling_fraction

        sampler = create_adaptive_sampler(scorer_class)
        CombinedSampler::SubSampler.new(sampler, sampling_fraction)
      end

      attr_reader :items, :goal_badness

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
