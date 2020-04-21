# frozen_string_literal: true

module TwistyPuzzles
  
    # Represents one type of puzzle.
    class Puzzle
      def initialize(name)
        @name = name
      end

      NXN_CUBE = Puzzle.new('nxn cube')
      SKEWB = Puzzle.new('skewb')

      attr_reader :name

      def eql?(other)
        self.class == other.class && name == other.name
      end

      def hash
        @hash ||= [self.class, @name].hash
      end

      alias == eql?
    end
end
