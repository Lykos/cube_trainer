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

    # If `buffer?` returns true, this is defined.
    def buffer_part_type
      raise NotImplementedError
    end

    def buffer?
      raise NotImplementedError
    end

    def self.parity_sets
      [
        ParitySet.new(TwistyPuzzles::Corner, TwistyPuzzles::Edge),
        ParitySet.new(TwistyPuzzles::Edge, TwistyPuzzles::Corner),
      ]
    end

    def self.three_cycle_sets
      TwistyPuzzles::PART_TYPES.map { |p| ThreeCycleSet.new(p) }
    end

    def self.twistable_part_types
      [TwistyPuzzles::Corner, TwistyPuzzles::Edge, TwistyPuzzles::Midge]
    end

    def self.floating_two_twist_sets
      twistable_part_types.map { |p| AbstractFloatingTwoTwistSet.new(p) }
    end

    def self.all
      @all ||= (three_cycle_sets + floating_two_twist_sets).freeze
    end
  end
end
