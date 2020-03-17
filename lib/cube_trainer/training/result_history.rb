# frozen_string_literal: true

require 'cube_trainer/utils/time_helper'
require 'set'

module CubeTrainer
  module Training
    # Keeps track of some per-item stats based on results.
    class ResultHistory
      include Utils::TimeHelper

      def initialize(
        results_model,
        badness_memory:,
        hint_seconds:,
        failed_seconds:
      )
        raise unless results_model.respond_to?(:results)

        @results_model = results_model
        @results_model.add_result_listener(self)
        @badness_memory = badness_memory
        @hint_seconds = hint_seconds
        @failed_seconds = failed_seconds
        @reset_listeners = []
        reset
      end

      # Reset caches and incremental state, recompute everything from scratch.
      def reset
        @current_occurrence_index = 0
        @occurrence_indices = {}
        @badness_histories = {}
        @badness_histories.default_proc = ->(h, k) { h[k] = new_cube_average }
        @occurrences = {}
        @occurrences.default = 0
        @last_hinted_days_ago = {}
        @occurrence_days_ago = {}
        @occurrence_days_ago.default_proc = ->(h, k) { h[k] = [] }
        @results_model.results.sort_by(&:timestamp).each do |r|
          record_result(r)
        end
        @reset_listeners.each(&:reset)
      end

      def add_reset_listener(listener)
        @reset_listeners.push(listener)
      end

      def new_cube_average
        Native::CubeAverage.new(@badness_memory, 0)
      end

      # Called by the results model to notify us about changes on the results.
      # It's not worth it to reimplement fancy logic here, we just recompute everything from
      # scratch.
      def delete_after_time(*_args)
        reset
      end

      # Called by the results model to notify us about changes on the results.
      # We don't need to do anything here.
      def replace_word(*_args); end

      # Badness for the given result.
      def result_badness(result)
        result.time_s + @failed_seconds * result.failed_attempts + @hint_seconds * result.num_hints
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
        update_badness_histories(result)
        update_occurrences(repr)
        days_ago = days_between(result.timestamp, Time.now)
        update_last_occurrence_days_ago(repr, days_ago)
        update_last_hinted_days_ago(result, days_ago)
      end

      def update_badness_histories(result)
        repr = result.input_representation
        @badness_histories[repr].push(result_badness(result))
      end

      def update_occurrences(input_representation)
        @current_occurrence_index += 1
        @occurrence_indices[input_representation] = @current_occurrence_index
        @occurrences[input_representation] += 1
      end

      def last_occurrence_days_ago(item)
        @occurrence_days_ago[item.representation].last
      end

      def update_last_occurrence_days_ago(input_representation, days_ago)
        occurrence_days_ago = @occurrence_days_ago[input_representation]
        return unless occurrence_days_ago.empty? || occurrence_days_ago.last > days_ago

        occurrence_days_ago.push(days_ago)
      end

      def update_last_hinted_days_ago(result, days_ago)
        return unless result.num_hints.positive?

        repr = result.input_representation
        @last_hinted_days_ago[repr] = days_ago
      end

      def badness_average(item)
        @badness_histories[item.representation].average
      end

      def occurrences(item)
        @occurrences[item.representation]
      end

      def occurred_today?(item)
        last_occurrence_days_ago(item)&.zero?
      end

      # On how many different days the item appeared.
      def occurrence_days(item)
        @occurrence_days_ago[item.representation].length
      end

      # On how many different days the item appeared since the user last used a hint for it.
      def occurrence_days_since_last_hint(item)
        last_hinted_days_ago = last_hinted_days_ago(item)
        return occurrence_days(item) if last_hinted_days_ago.nil?

        @occurrence_days_ago[item.representation].count do |days_ago|
          days_ago < last_hinted_days_ago
        end
      end

      def last_hinted_days_ago(item)
        @last_hinted_days_ago[item.representation]
      end
    end
  end
end
