# frozen_string_literal: true

require 'twisty_puzzles/utils/array_helper'

module TwistyPuzzles
  
    # Various constants about the cube.
    module CubeConstants
      include Utils::ArrayHelper

      # The order determines the priority of the faces.
      FACE_SYMBOLS = %i[U F R L B D].freeze
      OPPOSITE_FACE_SYMBOLS = [%i[U D], %i[F B], %i[R L]].freeze
      raise unless FACE_SYMBOLS.sort == OPPOSITE_FACE_SYMBOLS.flatten.sort

      FACE_NAMES = FACE_SYMBOLS.map(&:to_s).freeze
      ALPHABET_SIZE = 24
      # Stickers on each Skewb face.
      SKEWB_STICKERS = 5
      CHIRALITY_FACE_SYMBOLS = %i[U R F].freeze

      def opposite_face_symbol(face_symbol)
        candidates = OPPOSITE_FACE_SYMBOLS.select { |ss| ss.include?(face_symbol) }
        raise if candidates.length > 1
        raise ArgumentError, "Invalid face symbol #{face_symbol}." if candidates.empty?

        only(only(candidates).reject { |s| s == face_symbol })
      end

      def chirality_canonical_face_symbol(face_symbol)
        if CHIRALITY_FACE_SYMBOLS.include?(face_symbol)
          face_symbol
        else
          opposite_face_symbol(face_symbol)
        end
      end

      def valid_chirality?(face_symbols)
        # To make it comparable to our CHIRALITY_FACE_SYMBOLS, we switch each face used in c
        # different from the ones used in the CHIRALITY_FACE_SYMBOLS for the opposite face.
        canonical_face_symbols = face_symbols.map { |f| chirality_canonical_face_symbol(f) }

        # Each time we swap a face for the opposite, the chirality direction should be inverted.
        no_swapped_face_symbols = canonical_face_symbols.zip(face_symbols).count { |a, b| a != b }
        inverted = no_swapped_face_symbols.odd?
        inverted_face_symbols = inverted ? canonical_face_symbols.reverse : canonical_face_symbols

        # If the corner is not equal modulo rotation to CHIRALITY_FACE_SYMBOLS after this
        # transformation, the original corner had a bad chirality.
        turned_equals?(inverted_face_symbols, CHIRALITY_FACE_SYMBOLS)
      end
    end
end
