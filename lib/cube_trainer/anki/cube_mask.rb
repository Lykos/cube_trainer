# frozen_string_literal: true

require 'twisty_puzzles'

module CubeTrainer
  module Anki
    # Mask that masks some part of the cube before applying any moves.
    # This can be used e.g. to make edge permutation unimportant.
    # To be used for the cube visualizer.
    class CubeMask
      def self.from_name(example_name, cube_size, color)
        case example_name
        when :ll_edges_outside then new(Coordinate.edges_outside(Face::U, cube_size), color)
        else raise ArgumentError
        end
      end

      NAMES = [:ll_edges_outside].freeze
      def initialize(coordinates, color)
        @coordinates = coordinates
        @color = color
      end

      def apply_to(cube_state)
        @coordinates.each { |c| cube_state[c] = @color }
      end
    end
  end
end
