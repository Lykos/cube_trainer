require 'cube_trainer/utils/random_helper'

module CubeTrainer
  module Training
    class ResultHistory
      include Utils::RandomHelper

      def initialize(results_model,
                     epsilon_score:,
                     badness_memory:,
                     failed_seconds:)
        raise unless results_model.respond_to?(:results)

        @results_model = results_model
        @results_model.add_result_listener(self)
        @epsilon_score = epsilon_score
        @badness_memory = badness_memory
        @failed_seconds = failed_seconds
        reset
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

      def new_cube_average
        Native::CubeAverage.new(@badness_memory, @epsilon_score)
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
        result.time_s + @failed_seconds * result.failed_attempts
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

      def badness_average(item)
        @badness_histories[item.representation].average
      end

      def occurrences(item)
        @occurrences[item.representation]
      end

      # TODO: Move this to RepeatScorer
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
    end
  end
end
