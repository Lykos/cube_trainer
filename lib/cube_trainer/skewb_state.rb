require 'cube_trainer/coordinate'
require 'cube_trainer/cube'
require 'cube_trainer/cube_print_helper'
require 'cube_trainer/state_helper'
require 'cube_trainer/cube_constants'

module CubeTrainer

  class SkewbState
    include CubePrintHelper
    include StateHelper
    include CubeConstants

    def initialize(stickers)
      raise ArgumentError, "Cubes must have #{SIDES} sides." unless stickers.length == FACES
      raise ArgumentError, "All sides of a Skewb must have #{SKEWB_STICKERS} stickers." unless stickers.all? { |p| p.length == SKEWB_STICKERS }
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
      raise TypeError unless face.is_a?(Face)
      @stickers[face.piece_index]
    end

    def dup
      SkewbState.new(@stickers.map { |s| s.dup })
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

    # Mirrors across an arbitrary axis.
    def mirror!
      top = Face.for_face_symbol(:U)
      bottom = Face.for_face_symbol(:D)
      front = Face.for_face_symbol(:F)
      back = Face.for_face_symbol(:B)
      right = Face.for_face_symbol(:R)
      left = Face.for_face_symbol(:L)
      swaps = [
        [SkewbCoordinate.center(front), SkewbCoordinate.center(back)],
        [SkewbCoordinate.corner_index(front, 0), SkewbCoordinate.corner_index(back, 1)],
        [SkewbCoordinate.corner_index(front, 1), SkewbCoordinate.corner_index(back, 3)],
        [SkewbCoordinate.corner_index(front, 2), SkewbCoordinate.corner_index(back, 0)],
        [SkewbCoordinate.corner_index(front, 3), SkewbCoordinate.corner_index(back, 2)],
        [SkewbCoordinate.corner_index(bottom, 0), SkewbCoordinate.corner_index(bottom, 1)],
        [SkewbCoordinate.corner_index(bottom, 2), SkewbCoordinate.corner_index(bottom, 3)],
        [SkewbCoordinate.corner_index(top, 0), SkewbCoordinate.corner_index(top, 2)],
        [SkewbCoordinate.corner_index(top, 1), SkewbCoordinate.corner_index(top, 3)],
        [SkewbCoordinate.corner_index(right, 0), SkewbCoordinate.corner_index(right, 1)],
        [SkewbCoordinate.corner_index(right, 2), SkewbCoordinate.corner_index(right, 3)],
        [SkewbCoordinate.corner_index(left, 0), SkewbCoordinate.corner_index(left, 2)],
        [SkewbCoordinate.corner_index(left, 1), SkewbCoordinate.corner_index(left, 3)],
      ]
      swaps.each { |s| apply_sticker_cycle(s) }
    end

    def [](coordinate)
      sticker_array(coordinate.face)[coordinate.coordinate]
    end
  
    def []=(coordinate, color)
      sticker_array(coordinate.face)[coordinate.coordinate] = color
    end    
  
    def any_layer_solved?
      !solved_layers.empty?
    end

    # Returns the color of all solved layers. Empty if there is none.
    def solved_layers
      Face::ELEMENTS.select { |f| layer_at_face_solved?(f) }.collect { |f| self[SkewbCoordinate.center(f)] }
    end
    
    def layer_solved?(color)
      Face::ELEMENTS.any? { |f| self[SkewbCoordinate.center(f)] == color && layer_at_face_solved?(f) }
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
