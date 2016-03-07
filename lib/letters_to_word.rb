require 'cube'
require 'letter_pair'
require 'sampling_helper'

class LettersToWord

  include SamplingHelper
  
  def initialize(results_model)
    @results_model = results_model
  end

  BUFFER_CORNER = Corner.new([:yellow, :blue, :orange])
  raise "Invalid buffer corner." unless BUFFER_CORNER.valid?

  def self.letter_pairs(c)
    c.collect { |c| LetterPair.new(c) }
  end

  def self.generate_valid_pairs
    buffer_letters = BUFFER_CORNER.rotations.collect { |c| c.letter }
    valid_letters = ALPHABET - buffer_letters
    singles = letter_pairs(valid_letters.permutation(1))
    pairs = letter_pairs(valid_letters.permutation(2))
    pairs + singles
  end

  VALID_PAIRS = self.generate_valid_pairs

  def results
    @results_model.results
  end

  def random_letter_pair
    random_input(VALID_PAIRS, results)
  end
end
