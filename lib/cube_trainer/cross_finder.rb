# frozen_string_literal: true

require 'cube_trainer/core/coordinate'
require 'cube_trainer/core/move'
require 'cube_trainer/layer_subset_finder'

module CubeTrainer
  class CrossFinder < LayerSubsetFinder
    alias find_cross find_solutions

    def score_on_face(state, face)
      base = no_auf_score_on_face(state, face)
      adjusted = cross_adjustments(face).map do |move|
        move.apply_temporarily_to(state) do
          no_auf_score_on_face(state, face)
        end
      end.max
      [base + 1, adjusted].max
    end

    def cross_adjustments(face)
      (@cross_adjustments ||= {})[face] ||= Core::CubeDirection::NON_ZERO_DIRECTIONS.map { |d| Core::Algorithm.move(Core::FatMove.new(face, d, 1)) }
    end

    def no_auf_score_on_face(state, face)
      raise InvalidArgumentError, "Crosses for 2x2 don't make any sense." if state.n < 3
      if state.n > 3
        raise UnimplementedError, 'Scoring for crosses on big cubes in not implemented.'
      end

      cross_color = state[Core::Coordinate.center(face, 3)]
      face.neighbors.count do |neighbor|
        # There are two, but we just take one
        other_neighbor = (neighbor.neighbors & face.neighbors).first
        outer_coordinate = Core::Coordinate.from_face_distances(neighbor, 3, [[face, 0], [other_neighbor, 1]])
        inner_coordinate = Core::Coordinate.from_face_distances(face, 3, [[neighbor, 0], [other_neighbor, 1]])
        neighbor_color = state[Core::Coordinate.center(neighbor, 3)]
        state[outer_coordinate] == neighbor_color && state[inner_coordinate] == cross_color
      end
    end

    def face_color(_state, face)
      face.color
    end

    def solution_score
      5
    end

    def solved_colors(state)
      Core::Face::ELEMENTS.select { |f| no_auf_score_on_face(state, f) + 1 == solution_score }.collect { |f| state[Core::Coordinate.center(f, 3)] }
    end

    def generate_moves(_state)
      Core::FatMove::OUTER_MOVES.map { |m| Core::Algorithm.move(m) }
    end
  end
end
