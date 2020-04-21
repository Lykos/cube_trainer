# frozen_string_literal: true

require 'cube_trainer/bruteforce_finder'
require 'twisty_puzzles'

module CubeTrainer
  # Class that finds a solution that is related to a score on a face.
  class LayerSubsetFinder < BruteForceFinder
    def initialize(color_restrictions = nil, find_all_solutions = true)
      super(find_all_solutions)
      @color_restrictions = color_restrictions
    end

    def score_on_face(_state, _face)
      raise NotImplementedError
    end

    def face_color(_state, _face)
      raise NotImplementedError
    end

    def state_score(state)
      TwistyPuzzles::Face::ELEMENTS.map do |f|
        if @color_restrictions.nil? || @color_restrictions.include?(face_color(state, f))
          score_on_face(state, f)
        else
          0
        end
      end.max
    end
  end
end
