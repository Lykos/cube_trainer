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
