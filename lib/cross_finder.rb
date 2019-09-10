require 'coordinate'
require 'layer_subset_finder'
require 'move'

module CubeTrainer

  class CrossFinder < LayerSubsetFinder
    alias :find_cross :find_solutions

    def score_on_face(state, face)
      base = no_auf_score_on_face(state, face)
      adjusted = CubeDirection::NON_ZERO_DIRECTIONS.map do |d|
        move = FatMove.new(face, 1, d)
        move.apply_to(state)
        score = no_auf_score_on_face(state, face)
        move.invert.apply_to(state)
        score
      end.max
      [base + 1, adjusted].max
    end

    def no_auf_score_on_face(state, face)
      raise InvalidArgumentError, "Crosses for 2x2 don't make any sense." if state.n < 3
      raise UnimplementedError, "Scoring for crosses on big cubes in not implemented." if state.n > 3
      face.neighbors.count do |neighbor|
        other_neighbor = (neighbor.neighbors & face.neighbors).first
        outer_coordinate = Coordinate.from_face_distances(neighbor, 3, [[face, 0], [other_neighbor, 1]])
        inner_coordinate = Coordinate.from_face_distances(face, 3, [[neighbor, 0], [other_neighbor, 1]])
        state[outer_coordinate] == neighbor.color && state[inner_coordinate] == face.color
      end
    end

    def solution_score
      5
    end

    def solved_colors(state)
      Face::ELEMENTS.select { |f| no_auf_score_on_face(state, f) + 1 == solution_score }.collect { |f| f.color }
    end

    def generate_moves(state)
      FatMove::OUTER_MOVES.dup
    end
  end

end
