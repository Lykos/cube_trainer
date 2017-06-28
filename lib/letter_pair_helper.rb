require 'cube'
require 'letter_pair'

module LetterPairHelper

  def self.letter_pairs(c)
    c.collect { |c| LetterPair.new(c) }
  end

  def self.generate_twists
    twists = Corner::ELEMENTS.flat_map do |c|
      letters = c.rotations.collect { |r| r.letter }
      letter_pairs(letters.permutation(2))
    end
  end

  def self.generate_letter_pairs
    buffer_letters = Corner::BUFFER.rotations.collect { |c| c.letter }
    valid_letters = ALPHABET - buffer_letters
    letter_pairs(valid_letters.permutation(2))
  end

  def self.generate_redundant_twists
    TWISTS.select { |l| !SHOOT_LETTERS.include?(l.letters.first) }
  end

  # Letters that we shoot to by default.
  SHOOT_LETTERS = ['a', 'b', 'd', 'l', 'h', 't', 'p']
  LETTER_PAIRS = generate_letter_pairs
  TWISTS = generate_twists
  REDUNDANT_TWISTS = generate_redundant_twists

end
