require 'layer_subset_finder'
require 'coordinate'
require 'skewb_state'
require 'move'

module CubeTrainer

  # Helper class that finds how to solve a given layer on the Skewb.
  class SkewbLayerFinder < LayerSubsetFinder
    alias :find_layer :find_solutions

    MATCHING_CORNERS_HASH =
      begin
        hash = {}
        SkewbState::MATCHING_CORNERS.each do |a, b|
          hash[a.sort] = b
          hash[b.sort] = a
        end
        {}
      end

    def mismatch_on_outside(skewb_state, coordinates)
      raise ArgumentError unless coordinates.length == 2
      raise ArgumentError unless coordinates.all? { |c| c.is_a?(SkewbCoordinate) }
      friends = MATCHING_CORNERS_HASH[coordinates.sort]
      return false unless friends
      skewb_state[friends[0]] != skewb_state[friends[1]]
    end

    def score_on_face(skewb_state, face)
      face_color = skewb_state[SkewbCoordinate.center(face)]
      matching_coordinates = SkewbCoordinate.corners_on_face(face).select do |c|
        skewb_state[c] == face_color
      end
      naive_score = matching_coordinates.length
      has_mismatch = matching_coordinates.combination(2).all? do |cs|
        mismatch_on_outside(skewb_state, cs)
      end
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
