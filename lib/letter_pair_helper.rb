require 'cube'
require 'letter_pair'

module CubeTrainer

  module LetterPairHelper
  
    def self.letter_pairs(c)
      c.collect { |c| LetterPair.new(c) }
    end
  
    def rotations
      @rotations ||= begin
                       part_type::ELEMENTS.flat_map do |c|
                         letters = c.rotations.collect { |r| letter_scheme.letter(r) }
                         LetterPairHelper.letter_pairs(letters.permutation(2))
                       end
                     end
    end
  
    def neighbors
      @neighbors ||= begin
                       part_type::ELEMENTS.flat_map do |c|
                         letters = c.neighbors.collect { |r| letter_scheme.letter(r) }
                         LetterPairHelper.letter_pairs(letters.permutation(2))
                       end
                     end
    end
  
    def letter_pairs
      @letter_pairs ||= begin
                          buffer_letters = buffer.rotations.collect { |c| letter_scheme.letter(c) }
                          valid_letters = letter_scheme.alphabet - buffer_letters
                          LetterPairHelper.letter_pairs(valid_letters.permutation(2))
                        end
    end
  
    def redundant_twists
      @redunant_twists ||= begin
                             raise "Redundant twists are only defined for corners." if part_type != Corner
                             rotations.select { |l| !letter_scheme.shoot_letters(part_type).include?(letter_scheme.letter(c)) }
                           end
    end
  
  end

end
