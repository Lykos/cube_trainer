# frozen_string_literal: true

require 'cube_trainer/letter_pair_alg_set'
require 'cube_trainer/disjoint_union_hinter'

module CubeTrainer
  # Class that generates input items for alg sets that are the disjoint union of two alg sets.
  class DisjointUnionLetterPairAlgSet < LetterPairAlgSet
    def initialize(results_model, options, *alg_sets)
      @alg_sets = alg_sets
      super(results_model, options)
    end

    def restricted_hinter(alg_set)
      RestrictedHinter.new(alg_set.input_items.map(&:representation), alg_set.hinter)
    end

    def hinter
      @hinter ||= DisjointUnionHinter.new(@alg_sets.map { |a| restricted_hinter(a) })
    end

    def generate_input_items
      @alg_sets.collect_concat(&:input_items)
    end

    def goal_badness
      @goal_badness ||= @alg_sets.map(&:goal_badness).max
    end
  end
end
