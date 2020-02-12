# frozen_string_literal: true

require 'cube_trainer/core/skewb_state'

module CubeTrainer
  module SkewbLayerHelper
    MATCHING_CORNERS_HASH =
      begin
        hash = {}
        SkewbState::MATCHING_CORNERS.each do |a, b|
          hash[a.sort] = b
          hash[b.sort] = a
        end
        hash
      end

    def check_on_outside_internal(skewb_state, coordinates)
      raise ArgumentError unless coordinates.length == 2
      unless coordinates.all? { |c| c.is_a?(SkewbCoordinate) }
        raise ArgumentError
      end

      friends = MATCHING_CORNERS_HASH[coordinates.sort]
      return :not_adjacent unless friends

      if skewb_state[friends[0]] == skewb_state[friends[1]]
        :match
      else
        :mismatch
      end
    end

    def has_mismatch_on_outside(skewb_state, coordinates)
      coordinates.combination(2).any? do |cs|
        check_on_outside_internal(skewb_state, cs) == :mismatch
      end
    end

    def has_not_adjacent_on_outside(skewb_state, coordinates)
      coordinates.combination(2).any? do |cs|
        check_on_outside_internal(skewb_state, cs) == :not_adjacent
      end
    end

    def matching_corner_coordinates(skewb_state, face)
      face_color = skewb_state[SkewbCoordinate.for_center(face)]
      matching_coordinates = SkewbCoordinate.corners_on_face(face).select do |c|
        skewb_state[c] == face_color
      end
    end

    def score_on_face(skewb_state, face)
      matching_coordinates = matching_corner_coordinates(skewb_state, face)
      naive_score = matching_coordinates.length
      has_mismatch = has_mismatch_on_outside(skewb_state, matching_coordinates)
      has_mismatch ? naive_score - naive_score / 2 : naive_score
    end
  end
end
