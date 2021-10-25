# frozen_string_literal: true

require 'cube_trainer/utils/time_helper'
require 'cube_trainer/utils/sql_helper'
require 'set'

module CubeTrainer
  module Training
    # Keeps track of some per-item stats based on results.
    # Does intensive caching, so it shouldn't be reused beyond sampling of a handful of items.
    class ResultHistory
      include Utils::TimeHelper
      include Utils::SqlHelper

      def initialize(
        mode:,
        badness_memory:,
        hint_seconds:,
        failed_seconds:,
        cached_inputs: []
      )
        @mode = mode
        @badness_memory = badness_memory
        @hint_seconds = hint_seconds
        @failed_seconds = failed_seconds
        @cached_inputs = cached_inputs
      end

      def occurred_today?(item)
        last_occurrence_days_ago(item).zero?
      end

      # On how many different days the item appeared.
      def occurrence_days(item)
        occurrence_days_cache[item.representation]
      end

      def occurrences(item)
        occurrences_cache[item.representation]
      end

      # Infinite for items that have never occurred or never got a hint.
      def last_hint_age(item)
        last_hint_age_cache[item.representation]
      end

      def last_hint_days_ago(item)
        days(last_hint_age(item))
      end

      def badness_average(item)
        badness_averages[item.representation]
      end

      # Infinite for items that have never occurred.
      def last_occurrence_age(item)
        last_occurrence_age_cache[item.representation]
      end

      def last_occurrence_days_ago(item)
        days(last_occurrence_age(item))
      end

      def last_occurrence_minutes_ago(item)
        minutes(last_occurrence_age(item))
      end

      # On how many different days the item appeared since the user last used a hint for it.
      def occurrence_days_since_last_hint(item)
        # TODO: Don't recalculate this per item.
        (@occurrence_days_since_last_hint ||= {})[item.representation] ||=
          calculate_occurrence_days_since_last_hint(item)
      end

      def last_items(num_items)
        if @max_num_items.nil? || num_items > @max_num_items
          @max_num_items = num_items
          @last_items = @cached_inputs + fetch_last_items(num_items - @cached_inputs.length)
        end

        adjusted_num_items = [num_items, @last_items.length].min
        @last_items[-adjusted_num_items..]
      end

      def badness_averages
        @badness_averages ||=
          begin
            result = @mode.inputs.joins(:result)
                          .group(:input_representation)
                          .pluck(:input_representation, badness_array_exp).to_h
            result.transform_values! do |badnesses|
              new_cube_average.push_all(badnesses[0...@badness_memory])
            end
            # We ignore the cached inputs here because we don't know their outcomes yet.
            result.default = Float::NAN
            result.freeze
          end
      end

      private

      def badness_array_exp
        badness_exp =
          results_table[:time_s] +
          (results_table[:failed_attempts] * @failed_seconds) +
          (results_table[:num_hints] * @hint_seconds)
        created_at = results_table[:created_at]
        array_agg(badness_exp, order: created_at.desc)
      end

      def fetch_last_items(num_items)
        # We ignore the cached inputs here because they are handled at a different level.
        @mode
          .inputs
          .joins(:result)
          .order(created_at: :desc)
          .limit(num_items)
          .pluck(:input_representation).reverse
      end

      # On how many different days the item appeared since the user last used a hint for it.
      # Can be infinite if the user never used a hint.
      def calculate_occurrence_days_since_last_hint(item)
        last_hint_age = last_hint_age(item)
        return Float::INFINITY if last_hint_age.infinite?

        # We ignore the cached inputs here because we don't know whether they will trigger a hint.
        # TODO: Avoid having one query per item.
        @mode
          .inputs
          .joins(:result)
          .where(input_representation: item.representation)
          .where(days_old_exp.gt(days(last_hint_age)))
          .count
      end

      def results_table
        @results_table ||= Result.arel_table
      end

      def inputs_table
        @inputs_table ||= Input.arel_table
      end

      def last_hint_age_cache
        @last_hint_age_cache ||=
          begin
            result =
              @mode
              .inputs
              .joins(:result)
              .where(Result.arel_table[:num_hints].gt(0))
              .group(:input_representation)
              .minimum(age_exp)
            # We ignore the cached inputs here because we don't know whether they will trigger a
            # hint.
            result.default = Float::INFINITY
            result.freeze
          end
      end

      # Without taking cached_inputs into consideration.
      def raw_last_occurrence_age_cache
        @raw_last_occurrence_age_cache ||=
          begin
            result =
              @mode
              .inputs
              .joins(:result)
              .group(:input_representation)
              .minimum(age_exp)
            # We ignore the cached inputs here because we handle them in last_occurrence_cache.
            result.default = Float::INFINITY
            result.freeze
          end
      end

      def last_occurrence_age_cache
        @last_occurrence_age_cache ||=
          begin
            result = raw_last_occurrence_age_cache.dup
            @cached_inputs.each { |i| result[i.representation] = 0 }
            result.freeze
          end
      end

      def age_exp
        extract(:epoch, age(inputs_table[:created_at]))
      end

      def days_old_exp
        floor(age_exp / 86_400)
      end

      # rubocop:disable Metrics/MethodLength
      def occurrence_days_cache
        @occurrence_days_cache ||=
          begin
            result =
              @mode
              .inputs
              .joins(:result)
              .group(:input_representation)
              .distinct
              .count(days_old_exp)
            result.default = 0
            cached_items_not_seen_today =
              @cached_inputs.select do |i|
                raw_last_occurrence_age_cache[i.representation] > 1.day
              end
            cached_items_not_seen_today.each { |i| result[i.representation] += 1 }
            result.freeze
          end
      end
      # rubocop:enable Metrics/MethodLength

      def occurrences_cache
        @occurrences_cache ||=
          begin
            result = @mode.inputs.joins(:result).group(:input_representation).count
            result.default = 0
            @cached_inputs.each { |i| result[i.representation] += 1 }
            result.freeze
          end
      end

      def new_cube_average
        TwistyPuzzles::Native::CubeAverage.new(@badness_memory, 0)
      end
    end
  end
end
