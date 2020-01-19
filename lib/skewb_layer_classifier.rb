require 'skewb_state'
require 'skewb_layer_helper'

module CubeTrainer

  class SkewbLayerClassifier

    include SkewbLayerHelper

    def initialize(face, color_scheme)
      raise ArgumentError unless face.is_a?(Face)
      @state = color_scheme.solved_skewb_state
      @face = face
    end

    def classify_layer(algorithm)
      algorithm.apply_temporarily_to(@state) do
        score = score_on_face(@state, @face)
        if score == 2
          matching_coordinates = matching_corner_coordinates(@state, @face)
          if matching_coordinates.length > 2 || has_not_adjacent_on_outside(@state, matching_coordinates)
            "2_opposite_solved"
          else
            "2_adjacent_solved"
          end
        else
          "#{score}_solved"
        end
      end
    end

  end
  
end
