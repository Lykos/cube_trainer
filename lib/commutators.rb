require 'cube'
require 'letter_pair'
require 'sampling_helper'

class CornerCommutators
  
  include SamplingHelper
  
  def initialize(results_model)
    @results_model = results_model
  end
  
  def self.generate_valid_pairs
    buffer_letters = Corner::BUFFER.rotations.collect { |c| c.letter }
    valid_letters = ALPHABET - buffer_letters
    letter_pairs = valid_letters.permutation(2).collect { |c| LetterPair.new(c) }
    twists = Corner::ELEMENTS.flat_map do |c|
      letters = c.rotations.collect { |r| r.letter }
      letters.permutation(2).collect { |p| LetterPair.new(p) }
    end
    letter_pairs - twists
  end

  VALID_PAIRS = generate_valid_pairs

  def results
    @results_model.results
  end

  def random_letter_pair
    random_input(VALID_PAIRS, results)
  end
  
end
