require 'options'
require 'buffer_helper'
require 'stats_computer'

module CubeTrainer

  TWIST_LAST_CORNER_WITH_PARITY = true
  FLIP_LAST_EDGE_WITH_COMM = false

  class AbstractExpectedAlgsComputer
    def initialize(cube_numbers)
      @cube_numbers = cube_numbers
    end

    def cube_numbers_key
      raise NotImplementedError
    end

    def last_twist_with_parity?(num_targets, num_twists)
      TWIST_LAST_CORNER_WITH_PARITY && num_targets % 2 == 1
    end

    def last_flip_with_comm?(num_flips)
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

    def compute_expected_algs_for_num_targets(num_targets, num_twists)
      raise NotImplementedError
    end
  end

  class CornerCommutatorsComputer < AbstractExpectedAlgsComputer
    def cube_numbers_key
      :corner_targets_twists
    end

    def compute_expected_algs_for_num_targets(num_targets, num_twists)
      # We need one alg for 2 targets.
      # The parity alg is not a corner comm, so we round down.
      corner_comms = num_targets / 2
      # We have to do a 2 twist for the last twisted corner unless it's a parity in which case we instead need one comm more.
      maybe_last_twist_comm = if last_twist_with_parity?(num_targets, num_twists) && num_twists % 2 == 1 then 1 else 0 end
      corner_comms + maybe_last_twist_comm
    end
  end

  class EdgeCommutatorsComputer < AbstractExpectedAlgsComputer
    # With our system of swapping two edges, there is never edge parity.
    def cube_numbers_key
      :edge_targets_flips_no_parity
    end

    def compute_expected_algs_for_num_targets(num_targets, num_flips)
      # We need one alg for 2 targets.
      # With our system of swapping two edges, there is never edge parity.
      edge_comms = num_targets / 2
      maybe_last_flip_comm = if last_flip_with_comm?(num_flips) && num_flips % 2 == 1 then 1 else 0 end
      edge_comms + maybe_last_flip_comm
    end
  end

  class Corner3TwistsComputer < AbstractExpectedAlgsComputer
    def cube_numbers_key
      :corner_targets_twists
    end

    def compute_expected_algs_for_num_targets(num_targets, num_twists)
      # We only need one alg for 2 targets and only half of the times it's a 3 twist.
      # We can't do a 2 twist for single twisted corners, so we round down.
      (num_twists / 2) * 0.5
    end
  end

  class Floating2TwistsComputer < AbstractExpectedAlgsComputer
    def cube_numbers_key
      :corner_targets_twists
    end

    def compute_expected_algs_for_num_targets(num_targets, num_twists)
      # We only need one alg for 2 targets and only half of the times it's a 2 twist.
      floating2twists = (num_twists / 2) * 0.5
      # We have to do a 2 twist for the last twisted corner unless it's a parity in which case we instead need one comm more.
      maybe_last_twist = if !last_twist_with_parity?(num_targets, num_twists) && num_twists % 2 == 0 then 1 else 0 end
      floating2twists + maybe_last_twist
    end
  end

  class Floating2FlipsComputer < AbstractExpectedAlgsComputer
    def cube_numbers_key
      :edge_targets_flips_no_parity
    end

    def compute_expected_algs_for_num_targets(num_targets, num_flips)
      # We only need one alg for 2 targets
      floating2flips = num_flips / 2
      # We can either do the last flip with an extra comm or with an extra flip alg.
      maybe_last_flip = if !last_flip_with_comm?(num_flips) && num_flips % 2 == 1 then 1 else 0 end
      floating2flips + maybe_last_flip
    end
  end

  class CornerParitiesComputer < AbstractExpectedAlgsComputer
    def cube_numbers_key
      :corner_targets_twists
    end

    def compute_expected_algs_for_num_targets(num_targets, num_twists)
      num_targets % 2
    end
  end

  class ExpectedTimeComputer
    EXPECTED_ALGS_COMPUTER_CLASSES = {
      corner_commutators: CornerCommutatorsComputer,
      corner_3twists: Corner3TwistsComputer,
      floating_2twists: Floating2TwistsComputer,
      edge_commutators: EdgeCommutatorsComputer,
      floating_2flips: Floating2FlipsComputer,
      corner_parities: CornerParitiesComputer,
    }

    def initialize(options, results_persistence)
      @options = options
      @results_persistence = results_persistence
    end

    def cube_numbers
      @cube_numbers ||= YAML::load_file('data/cube_numbers.yml')
    end

    def compute_expected_time_per_type_stats
      relevant_commutator_types = Options::COMMUTATOR_TYPES.select { |k, c| EXPECTED_ALGS_COMPUTER_CLASSES.has_key?(c.result_symbol) }
      per_type_stats = relevant_commutator_types.map do |k, c|
        patched_options = @options.dup
        patched_options.commutator_info = c
        average = StatsComputer.new(patched_options, @results_persistence).total_average
        expected_algs = EXPECTED_ALGS_COMPUTER_CLASSES[c.result_symbol].new(cube_numbers).compute_expected_algs
        {name: k, expected_algs: expected_algs, average: average, total_time: expected_algs * average}
      end
      total_time = per_type_stats.map { |stats| stats[:total_time] }.reduce(:+)
      per_type_stats.each { |stats| stats[:weight] = stats[:total_time] / total_time }
      per_type_stats
    end
    
  end
  
end
