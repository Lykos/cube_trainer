# frozen_string_literal: true

require 'twisty_puzzles'

module CaseSets
  # A high level case set like edge 3-cycles.
  # This is not used for training, look for `ConcreteAlgSet` for one that includes a buffer
  # and can be used for training.
  class AbstractCaseSet
    include CaseSetHelper

    def refinements_matching(casee)
      raise NotImplementedError
    end

    # If `buffer?` returns true, this needs 1 argument, otherwise 0.
    def refinement
      raise NotImplementedError
    end

    # Returns true iff this case set has a buffer.
    def buffer?
      defined?(buffer_part_type)
    end

    # Returns true iff this case set has parity parts (of a different type than the buffer)
    def parity_parts?
      defined?(parity_part_type)
    end

    def part_types
      raise NotImplementedError
    end

    def min_cube_size
      candidate = part_types.map(&:min_cube_size).max

      return candidate if part_types.all? { |p| p.exists_on_cube_size?(candidate) }

      candidate += 1
      return candidate if part_types.all? { |p| p.exists_on_cube_size?(candidate) }

      raise
    end

    def max_cube_size
      candidate = part_types.map(&:max_cube_size).min

      return candidate if candidate.infinite?
      return candidate if part_types.all? { |p| p.exists_on_cube_size?(candidate) }

      candidate -= 1
      return candidate if part_types.all? { |p| p.exists_on_cube_size?(candidate) }

      raise
    end

    def odd_cube_size_allowed?
      part_types.all?(&:exists_on_odd_cube_sizes?)
    end

    def even_cube_size_allowed?
      part_types.all?(&:exists_on_even_cube_sizes?)
    end

    def self.parity_sets
      [
        ParitySet.new(TwistyPuzzles::Corner, TwistyPuzzles::Edge),
        ParitySet.new(TwistyPuzzles::Edge, TwistyPuzzles::Corner)
      ]
    end

    def self.parity_twist_sets
      [
        ParityTwistSet.new(TwistyPuzzles::Corner, TwistyPuzzles::Edge),
        ParityTwistSet.new(TwistyPuzzles::Edge, TwistyPuzzles::Corner)
      ]
    end

    def self.three_cycle_sets
      TwistyPuzzles::PART_TYPES.map { |p| ThreeCycleSet.new(p) }
    end

    def self.three_twist_sets
      [ThreeTwistSet.new]
    end

    def self.twistable_part_types
      [TwistyPuzzles::Corner, TwistyPuzzles::Edge, TwistyPuzzles::Midge]
    end

    def self.floating_two_twist_sets
      twistable_part_types.map { |p| AbstractFloatingTwoTwistSet.new(p) }
    end

    def self.all
      # TODO: Parity twist sets
      @all ||= (three_cycle_sets + floating_two_twist_sets + parity_sets + three_twist_sets).freeze
    end
  end
end
