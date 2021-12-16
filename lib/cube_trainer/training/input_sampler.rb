# frozen_string_literal: true

require 'colorize'
require 'twisty_puzzles'
require 'cube_trainer/training/badness_scorer'
require 'cube_trainer/training/coverage_scorer'
require 'cube_trainer/training/forgotten_scorer'
require 'cube_trainer/training/input_item'
require 'cube_trainer/training/new_scorer'
require 'cube_trainer/training/repeat_scorer'
require 'cube_trainer/training/result_history'
require 'cube_trainer/training/revisit_scorer'
require 'twisty_puzzles/utils'

module CubeTrainer
  module Training
    # An input sampler that tries to adaptively sample items that are useful inputs for the learner.
    class InputSampler
      DEFAULT_CONFIG = {
        # Boundary at which we don't punish repeating the same item again. But note that this will
        # be adjusted in case of a small total number of items.
        repetition_boundary: 4,

        # Exponent that is applied to the time since the last occurrence to punish items that
        # haven't been seen in a long time for coverage samples.
        index_exponent: 2,

        # Exponent that is applied to the time since the last occurrence to punish items that
        # haven't been seen in a lot of training days for day coverage samples.
        days_ago_exponent: 2,

        # Base that is taken to the power of the badness to punish bad samples.
        badness_base: 10,

        # Number of occurrences that we go back to the past to compute the badness of a given item.
        # Occurrences longer ago have no effect on the sampling any more.
        badness_memory: 5,

        # Number of seconds that are equivalent to one failed attempt.
        # (Used for calculating badness)
        failed_seconds: 60,

        # Number of seconds that are equivalent to getting one hint.
        # (Used for calculating badness)
        hint_seconds: 60,

        # The badness that we want to reach. If something is below this, we won't practice it much
        # any more.
        goal_badness: 1.0,

        # The number of repetitions at which we stop considering an item a "new item" that needs to
        # be repeated occasionally.
        repeat_new_item_times_boundary: 11,

        # The number of days where it occurred at which we stop considering an item a "new item"
        # that needs to be repeated occasionally.
        revisit_new_item_days_boundary: 5,

        # The number of training days where it occurred at which we stop considering an item a
        # "forgotten item" that needs to be repeated at least once per day.
        repeat_forgotten_item_days_boundary: 5
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

        # In case there are still completely new items available, this is the fraction of times
        # that such an item will be chosen.
        # This is used in case the algorithm set is marked as "known". The user knows the alg
        # set already, but we can't make good decisions until we have results for all of them,
        # so we want to get through all of them quickly and use a high fraction here.
        new_known: 2.0,

        # Fraction of the samples that prefers things we haven't seen in a while to also
        # occasionally cover easy cases.
        coverage: 0.15,

        # Fraction of samples that are just simply bad samples.
        badness: 0.75
      }.freeze

      # `items` are the items from which we get samples. They have to be an array of InputItem.
      #         But the case key inside InputItem can be anything.
      # `mode` is the mode that is used to retrieve associated previous results and for all kinds
      #        of options.
      def initialize(items, mode, logger = Rails.logger)
        raise ArgumentError unless items.is_a?(Array)
        raise ArgumentError, "Invalid items #{items.inspect}." unless items.all?(InputItem)

        @items = items
        @mode = mode
        @logger = logger
        @config = create_config
      end

      attr_reader :items

      def create_config
        config = DEFAULT_CONFIG.dup
        config[:num_items] = items.length
        config[:goal_badness] = @mode.goal_badness if @mode.goal_badness
        config[:known] = @mode.known
        config
      end

      def create_result_history(cached_cases)
        ResultHistory.new(
          mode: @mode,
          badness_memory: @config[:badness_memory],
          failed_seconds: @config[:failed_seconds],
          hint_seconds: @config[:hint_seconds],
          cached_cases: cached_cases
        )
      end

      def create_sampler
        samplers =
          [
            create_adaptive_sampler(ForgottenScorer),
            create_normal_sampler,
            UniformSampler.new(@items)
          ]
        unless @config[:known]
          samplers =
            [
              create_adaptive_sampler(RevisitScorer),
              create_adaptive_sampler(RepeatScorer)
            ] + samplers
        end
        PrioritizedSampler.new(samplers)
      end

      # The sampler that is used in "normal" cases, i.e. if no special sampling is needed.
      def create_normal_sampler
        new_fraction = @config[:known] ? SAMPLING_FRACTIONS[:new_known] : SAMPLING_FRACTIONS[:new]
        CombinedSampler.new(
          'normal_sampler',
          [
            create_adaptive_subsampler(BadnessScorer, SAMPLING_FRACTIONS[:badness]),
            CombinedSampler::SubSampler.new(create_coverage_sampler, SAMPLING_FRACTIONS[:coverage]),
            create_adaptive_subsampler(NewScorer, new_fraction)
          ]
        )
      end

      def create_coverage_sampler
        PrioritizedSampler.new(
          [create_adaptive_sampler(DaysCoverageScorer), create_adaptive_sampler(CoverageScorer)]
        )
      end

      def create_adaptive_sampler(scorer_class)
        scorer_class.new(@config, @result_history).create_adaptive_sampler(@items)
      end

      def create_adaptive_subsampler(scorer_class, sampling_fraction)
        raise ArgumentError unless sampling_fraction

        sampler = create_adaptive_sampler(scorer_class)
        CombinedSampler::SubSampler.new(sampler, sampling_fraction)
      end

      def random_item(cached_cases = [])
        @result_history = create_result_history(cached_cases)
        sampler = create_sampler
        managed_sample = sampler.random_item

        item = managed_sample.input_item
        @logger.debug "[#{item.case_key}] #{managed_sample.sampling_info}"
        item
      end
    end

    # A random input sampler that doesn't do anything special or smart.
    class RandomSampler
      def initialize(items)
        @items = items
      end

      attr_reader :items

      def random_item(_cached_cases = [])
        @items.sample
      end
    end
  end
end
