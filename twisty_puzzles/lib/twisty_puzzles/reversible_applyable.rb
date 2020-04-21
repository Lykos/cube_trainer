# frozen_string_literal: true

require 'twisty_puzzles/skewb_state'

module TwistyPuzzles
  
    # Module that makes a class that has an `apply_to` and `reverse` be able to apply temporarily.
    module ReversibleApplyable
      def apply_to_dupped(puzzle_state)
        dupped = puzzle_state.dup
        apply_to(dupped)
        dupped
      end

      # Applies the current algorithm/cycle/whatever to the given puzzle state and yields the
      # modified version. The puzzle state will be the same as the original after this function
      # returns.
      # Whether the yielded puzzle state is actually the same as the passed one or a copy is an
      # implementation detail.
      def apply_temporarily_to(puzzle_state)
        return yield(apply_to_dupped(puzzle_state)) if with_dup_is_faster?(puzzle_state)

        apply_to(puzzle_state)
        begin
          yield(puzzle_state)
        ensure
          inverse.apply_to(puzzle_state)
        end
      end

      private

      def with_dup_is_faster?(state)
        !state.is_a?(CubeState) || state.n <= 4
      end
    end
end
