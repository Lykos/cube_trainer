# frozen_string_literal: true

require 'cube_trainer/utils/time_helper'
require 'set'

module CubeTrainer
  module Training
    # Keeps track of some per-item stats based on results.
    # Does intensive caching, so it shouldn't be reused beyond sampling of a handful of items.
    class ResultHistory
      include Utils::TimeHelper

      def initialize(
        mode:,
        badness_memory:,
        hint_seconds:,
        failed_seconds:
      )
        @mode = mode
        @badness_memory = badness_memory
        @hint_seconds = hint_seconds
        @failed_seconds = failed_seconds
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
        badness_average_cache[item.representation]
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
        # TODO Don't recalculate this per item.
        (@occurrence_days_since_last_hint ||= {})[item.representation] ||= calculate_occurrence_days_since_last_hint(item)
      end

      def last_items(num_items)
        if @max_num_items.nil? || num_items > @max_num_items
          @max_num_items = num_items
          @last_items = @mode.inputs.joins(:result).order(created_at: :desc).limit(num_items).pluck(:input_representation).reverse
        end

        adjusted_num_items = [num_items, @last_items.length].min
        @last_items[-adjusted_num_items..-1]
      end

      private
      
      # On how many different days the item appeared since the user last used a hint for it.
      # Can be infinite if the user never used a hint.
      def calculate_occurrence_days_since_last_hint(item)
        last_hint_age = last_hint_age(item)
        if last_hint_age.infinite?
          return Float::INFINITY
        end

        # TODO Avoid having one query per item.
        @mode.inputs.joins(:result).where(input_representation: item.representation).where("date_trunc('day', inputs.created_at) > ?", last_hint_age - Time.now).count
      end

      def badness_average_cache
        @badness_average_cache ||=
          begin
            # TODO: Find a way to construct this with Arel.
            badness_array_expression = Arel.sql(@mode.inputs.sanitize_sql_for_conditions(['array_agg(results.time_s + ? * results.failed_attempts + ? * results.num_hints order by results.created_at desc)', @failed_seconds, @hint_seconds]))
            result = @mode.inputs.joins(:result).
                       group(:input_representation).
                       pluck(:input_representation, badness_array_expression).to_h
            result.transform_values! do |badnesses|
              badnesses[0...@badness_memory].inject(new_cube_average) { |avg, badness| avg.push(badness); avg }.average
            end
            result.default = Float::NAN
            result
          end
      end

      def last_hint_age_cache
        @last_occurrence_age_cache ||=
          begin
            now = Time.now
            result = @mode.inputs.joins(:result).where('results.num_hints > 0').group(:input_representation).maximum(:created_at).transform_values! { |time| now - time }
            result.default = Float::INFINITY
            result
          end
      end

      def last_occurrence_age_cache
        @last_occurrence_age_cache ||=
          begin
            now = Time.now
            result = @mode.inputs.joins(:result).group(:input_representation).maximum(:created_at).transform_values! { |time| now - time }
            result.default = Float::INFINITY
            result
          end
      end

      def occurrence_days_cache
        @occurrence_days_cache ||=
          begin
            result = @mode.inputs.joins(:result).group(:input_representation).distinct.count('floor(extract(epoch from age(inputs.created_at)) / 86400)')
            result.default = 0
            result
          end
      end

      def occurrences_cache
        @occurrences_cache ||=
          begin
            result = @mode.inputs.joins(:result).group(:input_representation).count
            result.default = 0
            result
          end
      end

      def new_cube_average
        Native::CubeAverage.new(@badness_memory, 0)
      end
    end
  end
end
