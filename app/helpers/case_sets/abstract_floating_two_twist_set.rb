# frozen_string_literal: true

require 'twisty_puzzles/utils'

module CaseSets
  # An alg set with all flaoting two twists of a given part type.
  class AbstractFloatingTwoTwistSet < AbstractCaseSet
    include TwistyPuzzles::Utils::StringHelper

    def initialize(part_type)
      super()
      @refinement = ConcreteFloatingTwoTwistSet.new(part_type)
    end

    attr_reader :refinement

    delegate :part_type, to: :refinement
    delegate :pattern, to: :refinement

    def to_s
      "floating #{simple_class_name(@part_type).downcase} 2-twists"
    end

    def refinements_matching(casee)
      return [] unless casee.part_cycles.length == 2 && casee.part_cycles.all? do |c|
                         c.length == 1 && c.twist > 0 && c.part_type == part_type
                       end

      [refinement]
    end

    def all_refinements
      [refinement]
    end

    def part_types
      [part_type]
    end
  end
end
