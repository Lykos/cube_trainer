# frozen_string_literal: true

require 'cube_trainer/core/abstract_direction'

module CubeTrainer
  module Core
    # Represents the direction of a Skewb move except a rotation.
    class SkewbDirection < AbstractDirection
      NUM_DIRECTIONS = 3
      NON_ZERO_DIRECTIONS = (1...NUM_DIRECTIONS).map { |d| new(d) }.freeze
      ALL_DIRECTIONS = Array.new(NUM_DIRECTIONS) { |d| new(d) }.freeze
      ZERO = new(0)
      FORWARD = new(1)
      BACKWARD = new(2)

      def name
        SIMPLE_SKEWB_DIRECTION_NAMES[@value]
      end

      def double_move?
        false
      end
    end
  end
end
