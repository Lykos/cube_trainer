# frozen_string_literal: true

require 'cube_trainer/abstract_scrambler'
require 'cube_trainer/core/skewb_move'

module CubeTrainer
  # Class to generate Skewb scrambles.
  class SkewbScrambler < AbstractScrambler
    def moves
      Core::SkewbNotation.fixed_corner.non_zero_moves
    end

    def excluded_next_moves(last_move)
      [last_move, last_move.inverse]
    end
  end
end
