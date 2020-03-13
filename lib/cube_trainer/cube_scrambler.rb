# frozen_string_literal: true

require 'cube_trainer/abstract_scrambler'
require 'cube_trainer/core/cube_move'

module CubeTrainer
  # Class to generate cube scrambles.
  class CubeScrambler < AbstractScrambler
    def moves
      Core::FatMove::OUTER_MOVES
    end

    def possible_next_moves(last_move)
      moves.reject { |m| m.same_axis?(last_move) }
    end
  end
end
