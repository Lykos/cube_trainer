# frozen_string_literal: true

module CubeTrainer
  module Core
    # Represents one type of puzzle.
    class Puzzle
      def initialize(name)
        @name = name
      end

      attr_reader :name

      def eql?(other)
        self.class == other.class && name == other.name
      end

      def hash
        @hash ||= [self.class, @name].hash
      end

      alias == eql?

      NXN_CUBE = Puzzle.new('nxn cube')
      SKEWB = Puzzle.new('skewb')
    end
  end
end
