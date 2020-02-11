require 'cube_trainer/core/coordinate'
require 'cube_trainer/core/cube'
require 'cube_trainer/core/cube_print_helper'
require 'cube_trainer/core/state_helper'
require 'cube_trainer/core/cube_constants'

module CubeTrainer

  module Core

  class SkewbState
    include CubePrintHelper
    include StateHelper
    include CubeConstants

    def initialize(native)
      raise TypeError unless native.is_a?(Native::SkewbState)
      @native = native
    end

    attr_reader :native

    def self.for_solved_colors(solved_colors)
      native = Native::SkewbState.new(solved_colors)
      new(native)
    end
  
    def eql?(other)
      self.class.equal?(other.class) && @native == other.native
    end
  
    alias == eql?
  
    def hash
      @hash ||= [self.class, @native].hash
    end

    # TODO Get rid of this backwards compatibility artifact
    def sticker_array(face)
      raise TypeError unless face.is_a?(Face)
      center_sticker = self[SkewbCoordinate.for_center(face)]
      corner_stickers = face.clockwise_corners.sort.map { |c| self[SkewbCoordinate.for_corner(c)] }
      [center_sticker] + corner_stickers
    end

    def dup
      SkewbState.new(@native.dup)
    end

    def to_s
      skewb_string(self, :nocolor)
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

    def [](coordinate)
      @native[coordinate.native]
    end
  
    def []=(coordinate, color)
      @native[coordinate.native] = color
      sticker_array(coordinate.face)[coordinate.coordinate] = color
    end    
  
    def any_layer_solved?
      !solved_layers.empty?
    end

    # Returns the color of all solved layers. Empty if there is none.
    def solved_layers
      Face::ELEMENTS.select { |f| layer_at_face_solved?(f) }.collect { |f| self[SkewbCoordinate.for_center(f)] }
    end
    
    def layer_solved?(color)
      Face::ELEMENTS.any? { |f| self[SkewbCoordinate.for_center(f)] == color && layer_at_face_solved?(f) }
    end

    def center_face(color)
      Face::ELEMENTS.find { |f| self[SkewbCoordinate.for_center(f)] == color }
    end

    # Pairs of coordinate pairs that should match in case of solved layers.
    MATCHING_CORNERS =
      begin
        matching_corners = []
        Corner::ELEMENTS.each do |c1|
          Corner::ELEMENTS.each do |c2|
            # Take corner pairs that have a common edge.
            next unless c1.has_common_edge_with?(c2)
            check_parts = []
            c1.rotations.each do |c1_rot|
              next unless c2.face_symbols.include?(c1_rot.face_symbols.first)
              c2_rot = c2.rotate_face_symbol_up(c1_rot.face_symbols.first)
              check_parts.push([SkewbCoordinate.for_corner(c1_rot), SkewbCoordinate.for_corner(c2_rot)])
            end
            matching_corners.push(check_parts)
          end
        end
        matching_corners.uniq
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
    def layer_at_face_solved?(face)
      return false unless native.face_solved?(face.face_symbol)
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
  
end
