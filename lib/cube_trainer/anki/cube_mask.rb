require 'cube_trainer/core/coordinate'

module CubeTrainer

  module Anki

  class CubeMask
    def self.from_name(example_name, cube_size, color)
      case example_name
      when :ll_edges_outside then new(Coordinate.edges_outside(Face::U, cube_size), color)
      else raise ArgumentError
      end
    end
    
    def initialize(coordinates, color)
      @coordinates = coordinates
      @color = color
    end

    NAMES = [:ll_edges_outside]
    
    def apply_to(cube_state)
      @coordinates.each { |c| cube_state[c] = @color }
    end
  end

  end
  
end
