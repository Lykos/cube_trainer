# frozen_string_literal: true

require 'cube_trainer/core/abstract_direction'

module CubeTrainer
  module Core
    # Represents the direction of a cube move or rotation.
    class CubeDirection < AbstractDirection
      NUM_DIRECTIONS = 4
      NON_ZERO_DIRECTIONS = (1...NUM_DIRECTIONS).map { |d| new(d) }.freeze
      ALL_DIRECTIONS = Array.new(NUM_DIRECTIONS) { |d| new(d) }.freeze
      FORWARD = new(1)
      DOUBLE = new(2)
      BACKWARD = new(3)

      def name
        SIMPLE_DIRECTION_NAMES[@value]
      end

      def double_move?
        @value == 2
      end
    end
  end
end
