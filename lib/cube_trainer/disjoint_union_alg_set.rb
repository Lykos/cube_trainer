# frozen_string_literal: true

require 'cube_trainer/letter_pair_alg_set'
require 'cube_trainer/disjoint_union_hinter'

module CubeTrainer
  class DisjointUnionLetterPairAlgSet < LetterPairAlgSet
    def initialize(results_model, options, *alg_sets)
      @alg_sets = alg_sets
      super(results_model, options)
    end

    def hinter
      @hinter ||= DisjointUnionHinter.new(@alg_sets.map { |a| RestrictedHinter.new(a.input_items.map(&:representation), a.hinter) })
    end

    def generate_input_items
      @alg_sets.collect_concat(&:input_items)
    end

    def goal_badness
      @goal_badness ||= @alg_sets.map(&:goal_badness).max
    end
  end
end
