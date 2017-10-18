require 'letter_pair_helper'
require 'sampling_helper'

class Commutators
  
  include SamplingHelper
  include LetterPairHelper
  
  def initialize(results_model)
    @results_model = results_model
  end

  def selector(pair)
    true
  end

  def results
    @results_model.results
  end

  def selectable_pairs
    @selectable_pairs ||= self.class::VALID_PAIRS.select { |p| selector(p) }
  end

  def random_letter_pair
    random_input(selectable_pairs, results)
  end
  
end

class CornerCommutators < Commutators
  
  VALID_PAIRS = CORNER_LETTER_PAIRS - TWISTS

  def badness_exponent
    6
  end
end

class SomeLettersCornerCommutators < CornerCommutators

  def initialize(results_model, letters)
    super(results_model)
    @letters = letters.collect { |l| l.downcase }
  end

  def selector(pair)
    !(pair.letters & @letters).empty?
  end

end

class EdgeCommutators < Commutators

  VALID_PAIRS = EDGE_LETTER_PAIRS - FLIPS

  def badness_exponent
    6
  end
  
end
