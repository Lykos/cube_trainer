require 'cube_trainer/reversible_applyable'

module CubeTrainer

  class CompiledSkewbAlgorithm

    include ReversibleApplyable

    def initialize(native)
      raise TypeError unless native.is_a?(Native::SkewbAlgorithm)
      @native = native
    end

    attr_reader :native
    attr_writer :inverse
    protected :inverse=

    def self.transform_move(move)
      if move.is_a?(Rotation) then [:rotation, move.axis_face.face_symbol, move.direction.value]
      elsif move.is_a?(SkewbMove) then [:move, move.axis_corner.face_symbols, move.direction.value]
      else raise TypeError
      end
    end

    def self.for_moves(moves)
      native = Native::SkewbAlgorithm.new(moves.map { |m| transform_move(m) })
      new(native)
    end

    EMPTY = for_moves([])

    def rotate_by(rotation)
      CompiledSkewbAlgorithm.new(@native.rotate_by(rotation.axis_face.face_symbol, rotation.direction.value))
    end                  
    
    def mirror(normal_face)
      CompiledSkewbAlgorithm.new(@native.mirror(normal_face.face_symbol))
    end

    def inverse
      @inverse ||= begin
                     alg = CompiledSkewbAlgorithm.new(@native.inverse)
                     alg.inverse = self
                     alg
                   end
    end

    def +(other)
      CompiledSkewbAlgorithm.new(@native + other.native)
    end
    
    def apply_to(skewb_state)
      @native.apply_to(skewb_state.native)
    end                  
    
  end
  
end
