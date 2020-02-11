require 'cube_trainer/utils/array_helper'

module CubeTrainer

  module Core

  module CubeConstants
      
    include Utils::ArrayHelper
    
    # The order determines the priority of the faces.
    FACE_SYMBOLS = [:U, :F, :R, :L, :B, :D]
    OPPOSITE_FACE_SYMBOLS = [[:U, :D], [:F, :B], [:R, :L]]
    raise unless FACE_SYMBOLS.sort == OPPOSITE_FACE_SYMBOLS.flatten.sort
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
    
    def chirality_canonical_face_symbol(face_symbol)
      CHIRALITY_FACE_SYMBOLS.include?(face_symbol) ? face_symbol : opposite_face_symbol(face_symbol)
    end
    
    def valid_chirality?(face_symbols)
      # To make it comparable to our CHIRALITY_FACE_SYMBOLS, we switch each face used in c
      # different from the ones used in the CHIRALITY_FACE_SYMBOLS for the opposite face.
      canonical_face_symbols = face_symbols.collect { |f| chirality_canonical_face_symbol(f) }
  
      # Each time we swap a face for the opposite, the chirality direction should be inverted.
      no_swapped_face_symbols = canonical_face_symbols.zip(face_symbols).count { |a, b| a != b }
      inverted = no_swapped_face_symbols % 2 == 1
      inverted_face_symbols = inverted ? canonical_face_symbols.reverse : canonical_face_symbols
  
      # If the corner is not equal modulo rotation to CHIRALITY_FACE_SYMBOLS after this transformation,
      # the original corner had a bad chirality.
      turned_equals?(inverted_face_symbols, CHIRALITY_FACE_SYMBOLS)
    end

  end

  end

end
