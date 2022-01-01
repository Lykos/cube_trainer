# frozen_string_literal: true

require 'cube_trainer/training/part_cycle_alg_set'

module CubeTrainer
  module Training
    # Class that generates input items for alg sets that are the disjoint union of two alg sets.
    class DisjointUnionPartCycleAlgSet < PartCycleAlgSet
      def initialize(training_session, *alg_sets)
        super(training_session)
        @alg_sets = alg_sets
      end

      def generate_input_items
        @alg_sets.collect_concat(&:input_items)
      end

      def goal_badness
        @goal_badness ||= @alg_sets.map(&:goal_badness).max
      end
    end
  end
end
