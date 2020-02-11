require 'cube_trainer/core/cube'
require 'cube_trainer/core/cube_constants'
require 'cube_trainer/core/coordinate'
require 'cube_trainer/core/cube_print_helper'
require 'cube_trainer/core/state_helper'
require 'cube_trainer/utils/array_helper'
require 'cube_trainer/native'

module CubeTrainer

  module Core

  class CubeState
      
    include Utils::ArrayHelper
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
  
    # TODO Get rid of this backwards compatibility artifact
    def sticker_array(face)
      raise TypeError unless face.is_a?(Face)
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
  
    def [](coordinate)
      @native[coordinate.native]
    end
  
    def []=(coordinate, color)
      @native[coordinate.native] = color
    end
    
  end

  end

end
