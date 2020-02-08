require 'cube_trainer/reversible_applyable'

module CubeTrainer

  class CompiledSkewbAlgorithm

    def initialize(native)
      @native = native
    end

    private_class_method :new

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

    def rotate_by(rotation)
      @native.rotate_by(rotation.axis_face.face_symbol, rotation.direction.value)
    end                  
    
    def mirror(normal_face)
      @native.mirror(normal_face.face_symbol)
    end                  
    
    def apply_to(skewb_state)
      @native.apply_to(skewb_state.native)
    end                  
    
  end
  
end
