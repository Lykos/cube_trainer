require 'cube_trainer/coordinate'
require 'cube_trainer/layer_subset_finder'
require 'cube_trainer/move'

module CubeTrainer

  class CrossFinder < LayerSubsetFinder

    alias :find_cross :find_solutions

    def score_on_face(state, face)
      base = no_auf_score_on_face(state, face)
      adjusted = CubeDirection::NON_ZERO_DIRECTIONS.map do |d|
        move = FatMove.new(face, d, 1)
        move.apply_temporarily_to(state) do
          no_auf_score_on_face(state, face)
        end
      end.max
      [base + 1, adjusted].max
    end

    def no_auf_score_on_face(state, face)
      raise InvalidArgumentError, "Crosses for 2x2 don't make any sense." if state.n < 3
      raise UnimplementedError, "Scoring for crosses on big cubes in not implemented." if state.n > 3
      cross_color = state[Coordinate.center(face, 3)]
      face.neighbors.count do |neighbor|
        # There are two, but we just take one
        other_neighbor = (neighbor.neighbors & face.neighbors).first
        outer_coordinate = Coordinate.from_face_distances(neighbor, 3, [[face, 0], [other_neighbor, 1]])
        inner_coordinate = Coordinate.from_face_distances(face, 3, [[neighbor, 0], [other_neighbor, 1]])
        neighbor_color = state[Coordinate.center(neighbor, 3)]
        state[outer_coordinate] == neighbor_color && state[inner_coordinate] == cross_color
      end
    end

    def face_color(state, face)
      face.color
    end

    def solution_score
      5
    end

    def solved_colors(state)
      Face::ELEMENTS.select { |f| no_auf_score_on_face(state, f) + 1 == solution_score }.collect { |f| state[Coordinate.center(f, 3)] }
    end

    def generate_moves(state)
      FatMove::OUTER_MOVES.map { |m| Algorithm.move(m) }
    end
  end

end
