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
        when :ll_edges_outside then new(TwistyPuzzles::Coordinate.edges_outside(TwistyPuzzles::Face::U, cube_size), color)
        when :ll then new(TwistyPuzzles::Coordinate.layer(TwistyPuzzles::Face::U, cube_size), color)
        else raise ArgumentError
        end
      end

      NAMES = %i[ll_edges_outside ll].freeze

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
