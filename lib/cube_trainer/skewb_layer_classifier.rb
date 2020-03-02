# frozen_string_literal: true

require 'cube_trainer/core/skewb_state'
require 'cube_trainer/skewb_layer_helper'

module CubeTrainer
  # Helper class to give a human readable description like '2_opposite_solved'
  # for a Skewb layer.
  class SkewbLayerClassifier
    include SkewbLayerHelper

    def initialize(face, color_scheme)
      raise ArgumentError unless face.is_a?(Core::Face)

      @state = color_scheme.solved_skewb_state
      @face = face
    end

    def classify_layer(algorithm)
      algorithm.apply_temporarily_to(@state) do |s|
        score = score_on_face(s, @face)
        score == 2 ? classify_score2_layer : "#{score}_solved"
      end
    end

    private

    def classify_score2_layer
      matching_coordinates = matching_corner_coordinates(@state, @face)
      if matching_coordinates.length > 2 ||
         contains_not_adjacent_on_outside?(@state, matching_coordinates)
        '2_opposite_solved'
      else
        '2_adjacent_solved'
      end
    end
  end
end
