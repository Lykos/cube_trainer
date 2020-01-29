require 'cube_trainer/cube'
require 'cube_trainer/cube_constants'
require 'cube_trainer/array_helper'
require 'cube_trainer/coordinate'
require 'cube_trainer/cube_print_helper'
require 'cube_trainer/state_helper'
require 'cube_trainer/native'

module CubeTrainer

  class CubeState
    include ArrayHelper
    include CubePrintHelper
    include StateHelper
    include CubeConstants

    def self.check_cube_size(n)
      raise TypeError unless n.is_a?(Integer)
      raise ArgumentError, 'Cubes of size smaller than 2 are not supported.' if n < 2
    end

    def self.from_stickers(n, stickers)
      CubeState.check_cube_size(n)
      raise ArgumentError, "Cubes must have #{FACE_SYMBOLS.length} sides." unless stickers.length == FACE_SYMBOLS.length
      raise ArgumentError, "All sides of a #{n}x#{n} must be #{n}x#{n}." unless stickers.all? { |p| p.length == n && p.all? { |q| q.length == n } }
      stickers_hash = FACE_SYMBOLS.zip(stickers).map do |face_symbol, face_stickers|
        face = Face.for_face_symbol(face_symbol)
        face_hash = {
          stickers: face_stickers,
          # Note that in the ruby code, x and y are exchanged s.t. one can say bla[x][y], but the C code does the more logical thing,
          # so we have to swap coordinates here.
          x_base_face_symbol: face.coordinate_index_base_face(1).face_symbol,
          y_base_face_symbol: face.coordinate_index_base_face(0).face_symbol,
        }
        [face_symbol, face_hash]
      end.to_h
      new(Native::CubeState.new(n, stickers_hash))
    end

    def initialize(native)
      raise TypeError unless native.is_a?(Native::CubeState)
      @native = native
    end

    def dup
      CubeState.new(@native.dup)
    end
  
    attr_reader :native

    def n
      @native.cube_size
    end
  
    def stickers
    end
  
    def eql?(other)
      self.class.equal?(other.class) && @native == other.native
    end
  
    alias == eql?
  
    def hash
      @hash ||= [self.class, @native].hash
    end
  
    def rotate_corner(corner)
      raise TypeError unless corner.is_a?(Corner)
      apply_sticker_cycle(corner.rotations.map { |c| Coordinate.solved_position(c, n, 0) })
    end

    def sticker_array(face)
      @native.sticker_array(
        face.face_symbol,
        # Note that in the ruby code, x and y are exchanged s.t. one can say bla[x][y], but the C code does the more logical thing,
        # so we have to swap coordinates here.
        face.coordinate_index_base_face(1).face_symbol,
        face.coordinate_index_base_face(0).face_symbol
      )
    end
  
    def to_s
      cube_string(self, :nocolor)
    end
  
    def find_cycles(pieces, incarnation_index)
      piece_positions = []
      pieces.each do |p|
        piece_positions.push(Coordinate.solved_positions(p, n, incarnation_index))
      end
      piece_positions[0].zip(*piece_positions[1..-1])
    end
  
    # Cycles the given positions. Note that it does NOT search for the given pieces and cycle them, rather, it cycles
    # the pieces that are at the position that those pieces would take in a solved state.
    def apply_piece_cycle(pieces, incarnation_index=0)
      raise 'Cycles of length smaller than 2 are not supported.' if pieces.length < 2
      raise 'Cycles of weird piece types are not supported.' unless pieces.all? { |p| p.is_a?(Part) }
      raise "Cycles of heterogenous piece types #{pieces.inspect} are not supported." if pieces.any? { |p| p.class != pieces.first.class }
      raise "Invalid incarnation index #{incarnation_index}." unless incarnation_index.is_a?(Integer) && incarnation_index >= 0
      raise "Incarnation index #{incarnation_index} for cube size #{n} is not supported for #{pieces.first.inspect}." unless incarnation_index < pieces.first.num_incarnations(n)
      pieces.each_with_index do |p, i|
        pieces.each_with_index do |q, j|
          if i != j && p.turned_equals?(q)
            raise "Pieces #{p} and #{q} are equal modulo rotation, so they can't be cycled."
          end
        end
      end
      cycles = find_cycles(pieces, incarnation_index)
      cycles.each { |c| apply_sticker_cycle(c) }
    end
  
    def [](coordinate)
      @native[coordinate.native]
    end
  
    def []=(coordinate, color)
      @native[coordinate.native] = color
    end
    
    def rotate_slice(face, slice, direction)
      @native.rotate_slice(face.face_symbol, slice, direction.value)
    end
  
    # Rotates the stickers on one face (not a real move, only stickers on one face!)
    def rotate_face(face, direction)
      @native.rotate_face(face.face_symbol, direction.value)
    end
  
    def apply(applyable)
      applyable.apply_to(self)
    end

    alias apply_move apply
    alias apply_algorithm apply

    def apply_rotation(rot)
      rot.apply_to_cube(self)
    end

  end

end
