require 'cube_trainer/reversible_applyable'

module CubeTrainer

  class CompiledCubeAlgorithm

    include ReversibleApplyable

    def initialize(native)
      raise TypeError unless native.is_a?(Native::CubeAlgorithm)
      @native = native
    end

    attr_reader :native
    attr_writer :inverse
    protected :inverse=

    def self.transform_move(move, cube_size)
      decided_move = move.decide_meaning(cube_size)
      if move.is_a?(Rotation)
        slice_moves = 0.upto(cube_size - 1).map do |i|
          [:slice, move.axis_face.face_symbol, move.direction.value, i]
        end
        [
          [:face, move.axis_face.face_symbol, move.direction.value]
          [:face, move.axis_face.opposite.face_symbol, move.direction.inverse.value]
        ] + slice_moves
      elsif move.is_a?(FatMSliceMove)
        1.upto(cube_size - 2).map do |i|
          [:slice, move.axis_face.face_symbol, move.direction.value, i]
        end
      elsif move.is_a?(SliceMove)  # Note that this also covers InnerMSliceMove
        [
          [:slice, move.axis_face.face_symbol, move.direction.value, move.slice_index]
        ]
      elsif move.is_a?(FatMove)
        slice_moves = 0.upto(move.width - 1).map do |i|
          [:slice, move.axis_face.face_symbol, move.direction.value, i]
        end
        [
          [:face, move.axis_face.face_symbol, move.direction.value]
        ] + slice_moves
      else
        raise TypeError
      end
    end

    def self.for_moves(cube_size, moves)
      native = Native::CubeAlgorithm.new(moves.collect_concat { |m| transform_move(m, cube_size) })
      new(native)
    end

    EMPTY = for_moves([])

    def rotate_by(rotation)
      CompiledCubeAlgorithm.new(@native.rotate_by(rotation.axis_face.face_symbol, rotation.direction.value))
    end                  
    
    def mirror(normal_face)
      CompiledCubeAlgorithm.new(@native.mirror(normal_face.face_symbol))
    end

    def inverse
      @inverse ||= begin
                     alg = CompiledCubeAlgorithm.new(@native.inverse)
                     alg.inverse = self
                     alg
                   end
    end

    def +(other)
      CompiledCubeAlgorithm.new(@native + other.native)
    end
    
    def apply_to(skewb_state)
      @native.apply_to(skewb_state.native)
    end                  
    
  end
  
end
