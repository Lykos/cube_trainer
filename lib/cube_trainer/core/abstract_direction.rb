# frozen_string_literal: true

module CubeTrainer
  module Core
    # Base class for directions.
    class AbstractDirection
      include Comparable
      POSSIBLE_DIRECTION_NAMES = [[''], ['2', '2\''], ['\'', '3']].freeze
      SIMPLE_DIRECTION_NAMES = (['0'] + POSSIBLE_DIRECTION_NAMES.map(&:first)).freeze
      POSSIBLE_SKEWB_DIRECTION_NAMES = [['', '2\''], ['\'', '2']].freeze
      SIMPLE_SKEWB_DIRECTION_NAMES = (['0'] + POSSIBLE_SKEWB_DIRECTION_NAMES.map(&:first)).freeze

      def initialize(value)
        raise TypeError, "Direction value #{value} isn't an integer." unless value.is_a?(Integer)
        unless value >= 0 && value < self.class::NUM_DIRECTIONS
          raise ArgumentError, "Invalid direction value #{value}."
        end

        @value = value
      end

      attr_reader :value

      def <=>(other)
        @value <=> other.value
      end

      def zero?
        @value.zero?
      end

      def non_zero?
        @value.positive?
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
  end
end
