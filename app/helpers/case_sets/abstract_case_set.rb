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

      def buffer?
        raise NotImplementedError
      end

      def self.all
        @all ||= TwistyPuzzles::PART_TYPES.map { |p| ThreeCycleSet.new(p) }.freeze
      end
    end
end
