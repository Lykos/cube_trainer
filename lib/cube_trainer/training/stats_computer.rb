# frozen_string_literal: true

require 'pry'
require 'cube_trainer/buffer_helper'
require 'twisty_puzzles'
require 'cube_trainer/training/probabilities'
require 'cube_trainer/utils/math_helper'

module CubeTrainer
  module Training
    # Helper class to compute all kinds of cubing stats
    class StatsComputer
      include Utils::MathHelper

      def initialize(now, _training_session)
        raise TypeError unless now.is_a?(Time)

        @now = now
        @mode = mode
      end

      def results_for_cases(cases)
        hashes = cases.map { |e| e.case_key.hash }
        grouped_results.select { |c, _rs| hashes.include?(c.hash) }
      end

      def newish_elements(filtered_results)
        lengths = filtered_results.map { |_input, rs| rs.length }
        new_item_boundary = InputSampler::DEFAULT_CONFIG[:repeat_new_item_times_boundary]
        lengths.count { |l| l >= 1 && l < new_item_boundary }
      end

      def case_stats(cases)
        filtered_results = results_for_cases(cases)
        found = filtered_results.keys.uniq.length
        total = cases.length
        missing = total - found
        {
          found: found, total: total,
          newish_elements: newish_elements(filtered_results),
          missing: missing
        }
      end

      def expected_time_per_type_stats
        @expected_time_per_type_stats ||=
          begin
            computer = ExpectedTimeComputer.new(@now, @mode)
            computer.compute_expected_time_per_type_stats
          end
      end

      def bad_results
        @bad_results ||=
          cutoffs.map do |cutoff|
            [cutoff, @averages.count { |v| v[1] > cutoff }]
          end
      end

      def compute_total_average(averages)
        if averages.empty?
          Float::INFINITY
        else
          averages.sum { |_c, t| t } / averages.length
        end
      end

      def total_average
        @total_average ||= compute_total_average(averages)
      end

      def old_total_average
        @old_total_average ||=
          begin
            old_results = results.select { |r| r.created_at < recently }
            old_averages = compute_averages(group_results(old_results))
            compute_total_average(old_averages)
          end
      end

      def average_time(results)
        avg = TwistyPuzzles::Native::CubeAverage.new(5, 0)
        results.sort_by(&:created_at).each { |r| avg.push(r.time_s) }
        avg.average
      end

      def num_results
        @num_results ||= results.length
      end

      def recently
        @now - (24 * 60 * 60)
      end

      def num_recent_results
        @num_recent_results ||= results.count { |r| r.created_at >= recently }
      end

      def averages
        @averages ||= compute_averages(grouped_results)
      end

      private

      def compute_averages(grouped_results)
        grouped_averages = grouped_results.map { |c, rs| [c, average_time(rs)] }
        grouped_averages.sort_by { |t| -t[1] }.freeze
      end

      def results
        @results ||= @mode.results
      end

      def grouped_results
        @grouped_results ||= group_results(results).freeze
      end

      def group_results(results)
        results.group_by(&:case_key)
      end

      # Interesting time boundaries to see the number of bad results above that boundary.
      # It allows to display things like "9 results are above 4.5 and one result is above 5".
      def cutoffs
        return [] if averages.length < 20

        # TODO: Take training_session and target into account
        some_bad_result = averages[9][1]
        step = floor_to_nice(some_bad_result / 10)
        start = floor_to_step(some_bad_result, step)
        finish = start + (step * 5)
        start.step(finish, step).to_a
      end
    end
  end
end
