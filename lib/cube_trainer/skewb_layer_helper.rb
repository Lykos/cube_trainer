# frozen_string_literal: true

require 'twisty_puzzles'

module CubeTrainer
  # Module with common helper methods related to Skewb layers.
  module SkewbLayerHelper
    MATCHING_CORNERS_HASH =
      begin
        hash = {}
        TwistyPuzzles::SkewbState::MATCHING_CORNERS.each do |a, b|
          hash[a.sort] = b
          hash[b.sort] = a
        end
        hash
      end

    def check_on_outside_internal(skewb_state, coordinates)
      raise ArgumentError unless coordinates.length == 2
      raise ArgumentError unless coordinates.all?(TwistyPuzzles::SkewbCoordinate)

      friends = MATCHING_CORNERS_HASH[coordinates.sort]
      return :not_adjacent unless friends

      if skewb_state[friends[0]] == skewb_state[friends[1]]
        :match
      else
        :mismatch
      end
    end

    def mismatch_on_outside?(skewb_state, coordinates)
      coordinates.combination(2).any? do |cs|
        check_on_outside_internal(skewb_state, cs) == :mismatch
      end
    end

    def contains_not_adjacent_on_outside?(skewb_state, coordinates)
      coordinates.combination(2).any? do |cs|
        check_on_outside_internal(skewb_state, cs) == :not_adjacent
      end
    end

    def matching_corner_coordinates(skewb_state, face)
      face_color = skewb_state[TwistyPuzzles::SkewbCoordinate.for_center(face)]
      TwistyPuzzles::SkewbCoordinate.corners_on_face(face).select do |c|
        skewb_state[c] == face_color
      end
    end

    def score_on_face(skewb_state, face)
      matching_coordinates = matching_corner_coordinates(skewb_state, face)
      naive_score = matching_coordinates.length
      has_mismatch = mismatch_on_outside?(skewb_state, matching_coordinates)
      has_mismatch ? naive_score - (naive_score / 2) : naive_score
    end
  end
end
