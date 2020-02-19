# frozen_string_literal: true

require 'cube_trainer/core/coordinate'
require 'cube_trainer/core/move'
require 'cube_trainer/layer_subset_finder'

module CubeTrainer
  # Class that finds a cross solution on a given 3x3 scramble.
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
      (@cross_adjustments ||= {})[face] ||= Core::CubeDirection::NON_ZERO_DIRECTIONS.map do |d|
        Core::Algorithm.move(Core::FatMove.new(face, d, 1))
      end
    end

    def no_auf_score_on_face(state, face)
      raise InvalidArgumentError, "Crosses for 2x2 don't make any sense." if state.n < 3
      if state.n > 3
        raise UnimplementedError, 'Scoring for crosses on big cubes in not implemented.'
      end

      cross_color = state[Core::Coordinate.center(face, 3)]
      face.neighbors.count { |neighbor| cross_part_solved?(state, face, cross_color, neighbor) }
    end

    def cross_part_solved?(state, face, cross_color, neighbor)
      # There are two, but we just take one
      other_neighbor = (neighbor.neighbors & face.neighbors).first
      neighbor_color = state[Core::Coordinate.center(neighbor, 3)]
      state[outer_coordinate(face, neighbor, other_neighbor)] == neighbor_color &&
        state[inner_coordinate(face, neighbor, other_neighbor)] == cross_color
    end

    def outer_coordinate(face, neighbor, other_neighbor)
      Core::Coordinate.from_face_distances(neighbor, 3, [[face, 0], [other_neighbor, 1]])
    end

    def inner_coordinate(face, neighbor, other_neighbor)
      Core::Coordinate.from_face_distances(face, 3, [[neighbor, 0], [other_neighbor, 1]])
    end

    def face_color(_state, face)
      face.color
    end

    def solution_score
      5
    end

    def solved_colors(state)
      solved_faces = Core::Face::ELEMENTS.select do |f|
        no_auf_score_on_face(state, f) + 1 == solution_score
      end
      solved_faces.collect { |f| state[Core::Coordinate.center(f, 3)] }
    end

    def generate_moves(_state)
      Core::FatMove::OUTER_MOVES.map { |m| Core::Algorithm.move(m) }
    end
  end
end
