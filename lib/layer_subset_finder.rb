require 'bruteforce_finder'
require 'cube'

module CubeTrainer

  class LayerSubsetFinder < BruteForceFinder
    def initialize(color_restrictions=COLORS, find_all_solutions=true)
      super(find_all_solutions)
      @color_restrictions = color_restrictions
    end

    def score_on_face(state, face)
      raise NotImplementedError
    end
 
    def face_color(state, face)
      raise NotImplementedError
    end

    def state_score(state)
      Face::ELEMENTS.collect do |f|
        if @color_restrictions.include?(face_color(state, f))
          score_on_face(state, f)
        else
          0
        end
      end.max
    end
  end

end
