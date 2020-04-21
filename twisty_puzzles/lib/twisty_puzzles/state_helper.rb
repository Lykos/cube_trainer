# frozen_string_literal: true

require 'twisty_puzzles/abstract_direction'

module TwistyPuzzles
  
    # Common utilities for different puzzle states.
    # TODO: Remove
    module StateHelper
      def apply_sticker_cycle(cycle)
        last_sticker = self[cycle[-1]]
        (cycle.length - 1).downto(1) do |i|
          self[cycle[i]] = self[cycle[i - 1]]
        end
        self[cycle[0]] = last_sticker
      end

      def apply_4sticker_cycle(cycle, direction)
        raise ArgumentError unless cycle.length == 4
        raise TypeError unless direction.is_a?(AbstractDirection)

        if direction.double_move?
          apply_sticker_cycle([cycle[0], cycle[2]])
          apply_sticker_cycle([cycle[1], cycle[3]])
        else
          # Note that we cannot do reverse! because the values are cached.
          actual_cycle = direction.value == 3 ? cycle.reverse : cycle
          apply_sticker_cycle(actual_cycle)
        end
      end
    end
end
