# frozen_string_literal: true

require 'cube_trainer/buffer_helper'
require 'cube_trainer/training/stats_computer'

module CubeTrainer
  module Training
    TWIST_LAST_CORNER_WITH_PARITY = true
    FLIP_LAST_EDGE_WITH_COMM = false

    # Common base class for expected number of algs computers.
    class AbstractExpectedAlgsComputer
      def initialize(cube_numbers)
        @cube_numbers = cube_numbers
      end

      def cube_numbers_key
        raise NotImplementedError
      end

      def last_twist_with_parity?(num_targets, _num_twists)
        TWIST_LAST_CORNER_WITH_PARITY && num_targets.odd?
      end

      def last_flip_with_comm?(_num_flips)
        FLIP_LAST_EDGE_WITH_COMM
      end

      def base_numbers
        @cube_numbers[cube_numbers_key]
      end

      def total
        @total ||= base_numbers.flatten.reduce(:+)
      end

      def compute_expected_algs
        @cube_numbers[cube_numbers_key].map.with_index do |numbers_by_num_twists, num_targets|
          numbers_by_num_twists.map.with_index do |number, num_twists|
            compute_expected_algs_for_num_targets(num_targets, num_twists) * number
          end
        end.flatten.reduce(:+) / (total + 0.0)
      end

      def compute_expected_algs_for_num_targets(_num_targets, _num_twists)
        raise NotImplementedError
      end

      def bool_to_i(bool)
        bool ? 1 : 0
      end
    end

    # Class that computes the expected number of corner commutators.
    class CornerCommutatorsComputer < AbstractExpectedAlgsComputer
      def cube_numbers_key
        :corner_targets_twists
      end

      def compute_expected_algs_for_num_targets(num_targets, num_twists)
        # We need one alg for 2 targets.
        # The parity alg is not a corner comm, so we round down.
        corner_comms = num_targets / 2
        # We have to do a 2 twist for the last twisted corner unless it's a parity in which
        # case we instead need one comm more.
        has_last_twist_comm = last_twist_with_parity?(num_targets, num_twists) && num_twists.odd?
        corner_comms + bool_to_i(has_last_twist_comm)
      end
    end

    # Class that computes the expected number of edge commutators.
    class EdgeCommutatorsComputer < AbstractExpectedAlgsComputer
      # With our system of swapping two edges, there is never edge parity.
      def cube_numbers_key
        :edge_targets_flips_no_parity
      end

      def compute_expected_algs_for_num_targets(num_targets, num_flips)
        # We need one alg for 2 targets.
        # With our system of swapping two edges, there is never edge parity.
        edge_comms = num_targets / 2
        has_last_flip_comm = last_flip_with_comm?(num_flips) && num_flips.odd?
        edge_comms + bool_to_i(has_last_flip_comm)
      end
    end

    # Class that computes the expected number of corner 3 twists.
    class Corner3TwistsComputer < AbstractExpectedAlgsComputer
      def cube_numbers_key
        :corner_targets_twists
      end

      def compute_expected_algs_for_num_targets(_num_targets, num_twists)
        # We only need one alg for 2 targets and only half of the times it's a 3 twist.
        # We can't do a 2 twist for single twisted corners, so we round down.
        (num_twists / 2) * 0.5
      end
    end

    # Class that computes the expected number of floating corner 2 twists.
    class Floating2TwistsComputer < AbstractExpectedAlgsComputer
      def cube_numbers_key
        :corner_targets_twists
      end

      def compute_expected_algs_for_num_targets(num_targets, num_twists)
        # We only need one alg for 2 targets and only half of the times it's a 2 twist.
        floating2twists = (num_twists / 2) * 0.5
        # We have to do a 2 twist for the last twisted corner unless it's a parity in which
        # case we instead need one comm more.
        has_last_twist = !last_twist_with_parity?(num_targets, num_twists) && num_twists.even?
        floating2twists + bool_to_i(has_last_twist)
      end
    end

    # Class that computes the expected number of floating edge 2 flips.
    class Floating2FlipsComputer < AbstractExpectedAlgsComputer
      def cube_numbers_key
        :edge_targets_flips_no_parity
      end

      def compute_expected_algs_for_num_targets(_num_targets, num_flips)
        # We only need one alg for 2 targets
        floating2flips = num_flips / 2
        # We can either do the last flip with an extra comm or with an extra flip alg.
        maybe_last_flip = !last_flip_with_comm?(num_flips) && num_flips.odd? ? 1 : 0
        floating2flips + maybe_last_flip
      end
    end

    # Class that computes the expected number of corner parities.
    class CornerParitiesComputer < AbstractExpectedAlgsComputer
      def cube_numbers_key
        :corner_targets_twists
      end

      def compute_expected_algs_for_num_targets(num_targets, _num_twists)
        num_targets % 2
      end
    end

    # Class that computes the expected time for BLD execution.
    class ExpectedTimeComputer
      EXPECTED_ALGS_COMPUTER_CLASSES = {
        corner_commutators: CornerCommutatorsComputer,
        corner_3twists: Corner3TwistsComputer,
        floating_2twists: Floating2TwistsComputer,
        edge_commutators: EdgeCommutatorsComputer,
        floating_2flips: Floating2FlipsComputer,
        corner_parities: CornerParitiesComputer
      }.freeze

      def initialize(now, mode)
        @now = now
        @mode = mode
      end

      def cube_numbers
        @cube_numbers ||= YAML.load_file('data/cube_numbers.yml')
      end

      def expected_algs(key)
        EXPECTED_ALGS_COMPUTER_CLASSES[key].new(cube_numbers).compute_expected_algs
      end

      def per_mode_stats(mode)
        average = StatsComputer.new(@now, mode).total_average
        expected_algs = expected_algs(mode.mode_type)
        {
          name: mode.mode_type,
          expected_algs: expected_algs,
          average: average,
          total_time: expected_algs * average
        }
      end

      def compute_expected_time_per_type_stats
        relevant_modes =
          @mode.user.modes.select do |m|
            EXPECTED_ALGS_COMPUTER_CLASSES.key?(m.mode_type)
          end
        per_type_stats = relevant_modes.map { |m| per_mode_stats(m) }
        total_time = per_type_stats.map { |stats| stats[:total_time] }.reduce(:+)
        per_type_stats.each { |stats| stats[:weight] = stats[:total_time] / total_time }
        per_type_stats
      end
    end
  end
end
