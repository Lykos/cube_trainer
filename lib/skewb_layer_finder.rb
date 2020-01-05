require 'layer_subset_finder'
require 'skewb_layer_helper'
require 'coordinate'
require 'skewb_state'
require 'move'

module CubeTrainer

  # Helper class that finds how to solve a given layer on the Skewb.
  class SkewbLayerFinder < LayerSubsetFinder
    alias :find_layer :find_solutions

    include SkewbLayerHelper

    def score_on_face(skewb_state, face)
      matching_coordinates = matching_corner_coordinates(skewb_state, face)
      naive_score = matching_coordinates.length
      has_mismatch = has_mismatch_on_outside(skewb_state, matching_coordinates)
      if has_mismatch then naive_score - naive_score / 2 else naive_score end
    end

    def face_color(state, face)
      state[SkewbCoordinate.center(face)]
    end

    def solved_colors(skewb_state)
      skewb_state.solved_layers & @color_restrictions
    end

    def solution_score
      4
    end

    def generate_moves(skewb_state)
      FixedCornerSkewbMove::ALL.dup
    end
  end
  
end
