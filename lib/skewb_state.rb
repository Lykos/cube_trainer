require 'coordinate'
require 'cube'
require 'cube_print_helper'
require 'state_helper'

module CubeTrainer

  class SkewbState
    include CubePrintHelper
    include StateHelper

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

    def dup
      @stickers.map { |s| s.dup }
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
  
    def apply_algorithm(alg)
      alg.apply_to(self)
    end

    def apply_rotation(rot)
      rot.apply_to_skewb(self)
    end

    # Mirrors across an arbitrary axis.
    def mirror!
      yellow = Face.for_color(:yellow)
      white = Face.for_color(:white)
      red = Face.for_color(:red)
      orange = Face.for_color(:orange)
      green = Face.for_color(:green)
      blue = Face.for_color(:blue)
      swaps = [
        [SkewbCoordinate.center(red), SkewbCoordinate.center(orange)],
        [SkewbCoordinate.corner_index(red, 0), SkewbCoordinate.corner_index(orange, 1)],
        [SkewbCoordinate.corner_index(red, 1), SkewbCoordinate.corner_index(orange, 3)],
        [SkewbCoordinate.corner_index(red, 2), SkewbCoordinate.corner_index(orange, 0)],
        [SkewbCoordinate.corner_index(red, 3), SkewbCoordinate.corner_index(orange, 2)],
        [SkewbCoordinate.corner_index(white, 0), SkewbCoordinate.corner_index(white, 1)],
        [SkewbCoordinate.corner_index(white, 2), SkewbCoordinate.corner_index(white, 3)],
        [SkewbCoordinate.corner_index(yellow, 0), SkewbCoordinate.corner_index(yellow, 2)],
        [SkewbCoordinate.corner_index(yellow, 1), SkewbCoordinate.corner_index(yellow, 3)],
        [SkewbCoordinate.corner_index(green, 0), SkewbCoordinate.corner_index(green, 1)],
        [SkewbCoordinate.corner_index(green, 2), SkewbCoordinate.corner_index(green, 3)],
        [SkewbCoordinate.corner_index(blue, 0), SkewbCoordinate.corner_index(blue, 2)],
        [SkewbCoordinate.corner_index(blue, 1), SkewbCoordinate.corner_index(blue, 3)],
      ]
      swaps.each { |s| apply_sticker_cycle(s) }
    end

    def [](coordinate)
      sticker_array(coordinate.face)[coordinate.coordinate]
    end
  
    def []=(coordinate, color)
      raise "All stickers on the cube must have a valid color." unless COLORS.include?(color)
      sticker_array(coordinate.face)[coordinate.coordinate] = color
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

    def center_face(color)
      Face::ELEMENTS.find { |f| self[SkewbCoordinate.center(f)] == color }
    end

    # Pairs of coordinate pairs that should match in case of solved layers.
    MATCHING_CORNERS =
      begin
        matching_corners = []
        Corner::ELEMENTS.each do |c1|
          Corner::ELEMENTS.each do |c2|
            # Take corner pairs that have a common edge.
            next if (c1.colors & c2.colors).length != 2
            check_parts = []
            c1.rotations.each do |c1_rot|
              next unless c2.colors.include?(c1_rot.colors.first)
              c2_rot = c2.rotate_color_up(c1_rot.colors.first)
              check_parts.push([SkewbCoordinate.for_corner(c1_rot), SkewbCoordinate.for_corner(c2_rot)])
            end
            matching_corners.push(check_parts)
          end
        end
        matching_corners
      end

    # Pairs of stickers that can be used to check whether the "outside" of a layer on the given face is
    # a proper layer.
    LAYER_CHECK_NEIGHBORS =
      begin
        layer_check_neighbors = {}
        MATCHING_CORNERS.each do |a, b|
          [[a.first.face, b], [b.first.face, a]].each do |face, coordinates|
            # We take the first one we encounter, but it doesn't matter, we could take any.
            layer_check_neighbors[face] ||= coordinates
          end
        end
        layer_check_neighbors
      end

    def layer_check_neighbors(face)
      LAYER_CHECK_NEIGHBORS[face]
    end

    # Note that this does NOT say that the layer corresponding to the given face is solved.
    # The face argument is used as the position where a solved face is present.
    def layer_solved_internal?(face)
      if sticker_array(face).uniq.length > 1 then return false end
      layer_check_neighbors(face).collect { |c| self[c] }.uniq.length == 1
    end

    def rotate_face(face, direction)
      neighbors = face.neighbors
      inverse_order_face = face.coordinate_index_close_to(neighbors[0]) < face.coordinate_index_close_to(neighbors[1])
      direction = direction.inverse if inverse_order_face
      cycle = SkewbCoordinate.corners_on_face(face)
      apply_4sticker_cycle(cycle, direction)
    end

  end
  
end
