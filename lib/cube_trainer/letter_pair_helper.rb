require 'cube_trainer/cube'
require 'cube_trainer/letter_pair'

module CubeTrainer

  module LetterPairHelper
  
    def self.letter_pairs(c)
      c.collect { |c| LetterPair.new(c) }
    end
  
    def rotations
      @rotations ||= begin
                       self.class::PART_TYPE::ELEMENTS.flat_map do |c|
                         letters = c.rotations.collect { |r| letter_scheme.letter(r) }
                         LetterPairHelper.letter_pairs(letters.permutation(2))
                       end
                     end
    end
  
    def neighbors
      @neighbors ||= begin
                       self.class::PART_TYPE::ELEMENTS.flat_map do |c|
                         letters = c.neighbors.collect { |r| letter_scheme.letter(r) }
                         LetterPairHelper.letter_pairs(letters.permutation(2))
                       end
                     end
    end
  
    def letter_pairs_for_piece
      @letter_pairs_for_piece ||= begin
                                    buffer_letters = buffer.rotations.collect { |c| letter_scheme.letter(c) }
                                    valid_letters = letter_scheme.alphabet - buffer_letters
                                    LetterPairHelper.letter_pairs(valid_letters.permutation(2))
                                  end
    end
  
    def redundant_twists
      @redunant_twists ||= begin
                             raise "Redundant twists are only defined for corners." if self.class::PART_TYPE != Corner
                             rotations.select { |l| !letter_scheme.shoot_letters(self.class::PART_TYPE).include?(letter_scheme.letter(c)) }
                           end
    end
  
  end

end
