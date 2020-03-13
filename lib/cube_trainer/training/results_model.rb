# frozen_string_literal: true

require 'cube_trainer/training/result'

module CubeTrainer
  module Training
    # Class that handles storing and querying results.
    class ResultsModel
      def initialize(mode, results_persistence)
        @mode = mode
        @result_persistence = results_persistence
        @results = @result_persistence.load_results(mode)
        @result_listeners = [@result_persistence]
      end

      attr_reader :mode, :results, :result_persistence

      def add_result_listener(listener)
        @result_listeners.push(listener)
      end

      def record_result(timestamp, partial_result, input)
        raise ArgumentError unless partial_result.is_a?(PartialResult)

        result = Result.from_partial(@mode, timestamp, partial_result, input)
        results.unshift(result)
        @result_listeners.each { |l| l.record_result(result) }
      end

      def delete_after_time(timestamp)
        results.delete_if { |r| r.timestamp + r.time_s > timestamp }
        @result_listeners.each { |l| l.delete_after_time(@mode, timestamp) }
      end

      def last_word_for_input(input_representation)
        result = results.select do |r|
          r.input_representation == input_representation
        end.max_by(&:timestamp)
        result.nil? ? nil : result.word
      end

      def inputs_for_word(word)
        results.select { |r| r.word == word }.map(&:input).uniq
      end
    end
  end
end
