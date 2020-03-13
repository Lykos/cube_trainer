# frozen_string_literal: true

require 'cube_trainer/abstract_scrambler'
require 'cube_trainer/core/skewb_move'

module CubeTrainer
  # Class to generate Skewb scrambles.
  class SkewbScrambler < AbstractScrambler
    def moves
      Core::SkewbNotation.fixed_corner.non_zero_moves
    end

    def possible_next_moves(last_move)
      moves.reject { |m| m.axis_corner == last_move.axis_corner }
    end
  end
end
