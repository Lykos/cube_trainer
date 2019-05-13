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
                         letters = c.rotations.collect { |r| r.letter }
                         LetterPairHelper.letter_pairs(letters.permutation(2))
                       end
                     end
    end
  
    def neighbors
      @neighbors ||= begin
                       part_type::ELEMENTS.flat_map do |c|
                         letters = c.neighbors.collect { |r| r.letter }
                         LetterPairHelper.letter_pairs(letters.permutation(2))
                       end
                     end
    end
  
    def letter_pairs
      @letter_pairs ||= begin
                          buffer_letters = buffer.rotations.collect { |c| c.letter }
                          valid_letters = ALPHABET - buffer_letters
                          LetterPairHelper.letter_pairs(valid_letters.permutation(2))
                        end
    end
  
    def redundant_twists
      @redunant_twists ||= begin
                             raise "Redundant twists are only defined for corners." if part_type != Corner
                             rotations.select { |l| !SHOOT_LETTERS.include?(l.letters.first) }
                           end
    end
  
    # Letters that we shoot to by default.
    def shoot_letters
      ['a', 'b', 'd', 'l', 'h', 't', 'p']
    end
  
  end

end
