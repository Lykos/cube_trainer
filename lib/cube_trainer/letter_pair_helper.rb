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
      self.class::PART_TYPE::ELEMENTS.flat_map do |c|
        letters = c.rotations.map { |r| letter(r) }
        LetterPairHelper.letter_pairs(letters.permutation(2))
      end
    end

    def neighbors
      self.class::PART_TYPE::ELEMENTS.flat_map do |c|
        letters = c.neighbors.map { |r| letter(r) }
        LetterPairHelper.letter_pairs(letters.permutation(2))
      end
    end

    def letter_pairs_for_part_type
      buffer_letters =
        @mode.parsed_buffer.rotations.map { |c| letter(c) }
      valid_letters = @mode.letter_scheme.alphabet - buffer_letters
      LetterPairHelper.letter_pairs(valid_letters.permutation(2))
    end

    def letter(part)
      @mode.letter_scheme.letter(part)
    end

    def letter_pair_for_parts(part_pair)
      LetterPair.new(part_pair.map { |p| letter(p) })
    end
  end
end
