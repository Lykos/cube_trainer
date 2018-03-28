require 'coordinate'
require 'cube'
require 'cube_print_helper'

module CubeTrainer

  class SkewbState
    include CubePrintHelper

    SIDES = COLORS.length

    def initialize(stickers)
      raise "Cubes must have #{SIDES} sides." unless stickers.length == SIDES
      raise "All sides of a Skewb must have #{SKEWB_STICKERS} stickers." unless stickers.all? { |p| p.length == SKEWB_STICKERS }
      raise 'All stickers on the cube must have a valid color.' unless stickers.all? { |p| p.all? { |c| COLORS.include?(c) } }
      @stickers = stickers
    end

    attr_reader :stickers
  
    def eql?(other)
      self.class.equal?(other.class) && @stickers == other.stickers
    end
  
    alias == eql?
  
    def hash
      @stickers.hash
    end

    def sticker_array(face)
      @stickers[face.piece_index]
    end

    def to_s
      skewb_string(self, :nocolor)
    end

    def self.solved
      stickers = COLORS.collect do |c|
        [c] * SKEWB_STICKERS
      end
      SkewbState.new(stickers)
    end
  
    def apply_move(move)
      move.apply_to(self)
    end

    def [](coordinate)
      sticker_array(coordinate.face)[coordinate.coordinate]
    end
  
    def []=(coordinate, color)
      raise "All stickers on the cube must have a valid color." unless COLORS.include?(color)
      sticker_array(coordinate.face)[coordinate.coordinate] = color
    end    
  
    def apply_index_cycle(cycle)
      last_sticker = self[cycle[-1]]
      (cycle.length - 1).downto(1) do |i|
        self[cycle[i]] = self[cycle[i - 1]]
      end
      self[cycle[0]] = last_sticker
    end

    def any_layer_solved?
      !solved_layers.empty?
    end

    # Returns the color of all solved layers. Empty if there is none.
    def solved_layers
      Face::ELEMENTS.select { |f| layer_solved_internal?(f) }.collect { |f| self[SkewbCoordinate.center(f)] }
    end
    
    def layer_solved?(color)
      Face::ELEMENTS.any? { |f| self[SkewbCoordinate.center(f)] == color && layer_solved_internal?(f) }
    end

    # Two coordinates that can be used to check whether the "outside" of a layer on the given face is
    # a proper layer
    def layer_check_neighbors(face)
      case face.color
      when :white
        [SkewbCoordinate.new(Face.for_color(:red), 2), SkewbCoordinate.new(Face.for_color(:red), 4)]
      when :yellow
        [SkewbCoordinate.new(Face.for_color(:red), 1), SkewbCoordinate.new(Face.for_color(:red), 3)]
      when :red
        [SkewbCoordinate.new(Face.for_color(:yellow), 1), SkewbCoordinate.new(Face.for_color(:yellow), 2)]
      when :green
        [SkewbCoordinate.new(Face.for_color(:yellow), 2), SkewbCoordinate.new(Face.for_color(:yellow), 4)]
      when :blue
        [SkewbCoordinate.new(Face.for_color(:yellow), 1), SkewbCoordinate.new(Face.for_color(:yellow), 3)]
      when :orange
        [SkewbCoordinate.new(Face.for_color(:yellow), 3), SkewbCoordinate.new(Face.for_color(:yellow), 4)]
      else
        raise
      end
    end

    # Note that this does NOT say that the layer corresponding to the given face is solved.
    # The face argument is used as the position where a solved face is present.
    def layer_solved_internal?(face)
      if sticker_array(face).uniq.length > 1 then return false end
      layer_check_neighbors(face).collect { |c| self[c] }.uniq.length == 1
    end

  end
  
end
