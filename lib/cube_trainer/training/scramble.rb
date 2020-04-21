# frozen_string_literal: true

require 'twisty_puzzles'

module CubeTrainer
  module Training
    # Class that holds a scramble and potentially some metadata.
    class Scramble
      extend Core
      def initialize(algorithm)
        @algorithm = algorithm
      end

      def to_s
        @algorithm.to_s
      end

      def to_raw_data
        @algorithm.to_s
      end

      def self.from_raw_data(raw_algorithm)
        new(parse_cube_algorithm(raw_algorithm))
      end
    end
  end
end
