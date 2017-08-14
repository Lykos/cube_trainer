require 'cube'
require 'letter_pair'

module LetterPairHelper

  def self.letter_pairs(c)
    c.collect { |c| LetterPair.new(c) }
  end

  def self.generate_rotations(part_type)
    part_type::ELEMENTS.flat_map do |c|
      letters = c.rotations.collect { |r| r.letter }
      letter_pairs(letters.permutation(2))
    end
  end

  def self.generate_letter_pairs(part_type)
    buffer_letters = part_type::BUFFER.rotations.collect { |c| c.letter }
    valid_letters = ALPHABET - buffer_letters
    letter_pairs(valid_letters.permutation(2))
  end

  def self.generate_redundant_twists
    TWISTS.select { |l| !SHOOT_LETTERS.include?(l.letters.first) }
  end

  # Letters that we shoot to by default.
  SHOOT_LETTERS = ['a', 'b', 'd', 'l', 'h', 't', 'p']
  CORNER_LETTER_PAIRS = generate_letter_pairs(Corner)
  EDGE_LETTER_PAIRS = generate_letter_pairs(Edge)
  TWISTS = generate_rotations(Corner)
  REDUNDANT_TWISTS = generate_redundant_twists
  FLIPS = generate_rotations(Edge)

end
