# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles'
require 'twisty_puzzles'
require 'twisty_puzzles'
require 'cube_trainer/layer_subset_finder'
require 'cube_trainer/skewb_layer_helper'

module CubeTrainer
  # Helper class that finds how to solve a given layer on the Skewb.
  class SkewbLayerFinder < LayerSubsetFinder
    alias find_layer find_solutions

    include SkewbLayerHelper

    def face_color(state, face)
      state[TwistyPuzzles::SkewbCoordinate.for_center(face)]
    end

    def solved_colors(skewb_state)
      if @color_restrictions
        skewb_state.solved_layers & @color_restrictions
      else
        skewb_state.solved_layers
      end
    end

    def solution_score
      4
    end

    def generate_moves(_skewb_state)
      TwistyPuzzles::SkewbNotation.fixed_corner.non_zero_moves.map do |m|
        TwistyPuzzles::Algorithm.move(m)
      end
    end
  end
end
