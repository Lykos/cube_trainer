# frozen_string_literal: true

module CubeTrainer
  module Core
    class AbstractDirection
      POSSIBLE_DIRECTION_NAMES = [[''], ['2', '2\''], ['\'', '3']].freeze
      SIMPLE_DIRECTION_NAMES = ['0'] + POSSIBLE_DIRECTION_NAMES.map(&:first)
      POSSIBLE_SKEWB_DIRECTION_NAMES = [['', '2\''], ['\'', '2']].freeze
      SIMPLE_SKEWB_DIRECTION_NAMES = ['0'] + POSSIBLE_SKEWB_DIRECTION_NAMES.map(&:first)

      def initialize(value)
        unless value.is_a?(Integer)
          raise ArgumentError, "Direction value #{value} isn't an integer."
      end
        unless value >= 0 && value < self.class::NUM_DIRECTIONS
          raise ArgumentError, "Invalid direction value #{value}."
      end

        @value = value
      end

      attr_reader :value

      def <=>(other)
        @value <=> other.value
      end

      include Comparable

      def is_zero?
        @value == 0
      end

      def is_non_zero?
        @value > 0
      end

      def inverse
        self.class.new((self.class::NUM_DIRECTIONS - @value) % self.class::NUM_DIRECTIONS)
      end

      def +(other)
        self.class.new((@value + other.value) % self.class::NUM_DIRECTIONS)
      end

      def eql?(other)
        self.class.equal?(other.class) && @value == other.value
      end

      alias == eql?

      def hash
        @value.hash
      end
    end

    class SkewbDirection < AbstractDirection
      NUM_DIRECTIONS = 3
      NON_ZERO_DIRECTIONS = (1...NUM_DIRECTIONS).map { |d| new(d) }
      ALL_DIRECTIONS = (0...NUM_DIRECTIONS).map { |d| new(d) }
      FORWARD = new(1)
      BACKWARD = new(2)

      def name
        SIMPLE_SKEWB_DIRECTION_NAMES[@value]
      end

      def is_double_move?
        false
      end
    end

    class CubeDirection < AbstractDirection
      NUM_DIRECTIONS = 4
      NON_ZERO_DIRECTIONS = (1...NUM_DIRECTIONS).map { |d| new(d) }
      ALL_DIRECTIONS = (0...NUM_DIRECTIONS).map { |d| new(d) }
      FORWARD = new(1)
      DOUBLE = new(2)
      BACKWARD = new(3)

      def name
        SIMPLE_DIRECTION_NAMES[@value]
      end

      def is_double_move?
        @value == 2
      end
    end
  end
end
