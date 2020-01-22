require 'cube_trainer/array_helper'

module CubeTrainer

  module CubeConstants
    include ArrayHelper
    # The order determines the priority of the faces.
    FACE_SYMBOLS = [:U, :F, :R, :L, :B, :D]
    OPPOSITE_FACE_SYMBOLS = [[:U, :D], [:F, :B], [:R, :L]]
    raise unless FACE_SYMBOLS.sort == OPPOSITE_FACE_SYMBOLS.flatten.sort
    FACES = FACE_SYMBOLS.length
    FACE_NAMES = FACE_SYMBOLS.map { |s| s.to_s }
    ALPHABET_SIZE = 24
    # Stickers on each Skewb face.
    SKEWB_STICKERS = 5
    CHIRALITY_FACE_SYMBOLS = [:U, :R, :F]

    def opposite_face_symbol(face_symbol)
      candidates = OPPOSITE_FACE_SYMBOLS.select { |ss| ss.include?(face_symbol) }
      raise if candidates.length > 1
      raise ArgumentError, "Invalid face symbol #{face_symbol}." if candidates.empty?
      only(only(candidates).select { |s| s != face_symbol })
    end
    
  end    

end
