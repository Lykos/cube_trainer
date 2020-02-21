# frozen_string_literal: true

require 'cube_trainer/core/cube'
require 'cube_trainer/letter_pair'

module CubeTrainer
  # Module to generate letter pairs that have certain meanings on the cube.
  module LetterPairHelper
    def self.letter_pairs(letterss)
      letterss.map { |ls| LetterPair.new(ls) }
    end

    def rotations
      @rotations ||=
        begin
          self.class::PART_TYPE::ELEMENTS.flat_map do |c|
            letters = c.rotations.map { |r| letter_scheme.letter(r) }
            LetterPairHelper.letter_pairs(letters.permutation(2))
          end
        end
    end

    def neighbors
      @neighbors ||=
        begin
          self.class::PART_TYPE::ELEMENTS.flat_map do |c|
            letters = c.neighbors.map { |r| letter_scheme.letter(r) }
            LetterPairHelper.letter_pairs(letters.permutation(2))
          end
        end
    end

    def letter_pairs_for_piece
      @letter_pairs_for_piece ||=
        begin
          buffer_letters =
            buffer.rotations.map { |c| letter_scheme.letter(c) }
          valid_letters = letter_scheme.alphabet - buffer_letters
          LetterPairHelper.letter_pairs(valid_letters.permutation(2))
        end
    end
  end
end
