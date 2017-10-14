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

  def goal_badness
    2.0
  end

end

class OneLetterCornerCommutators < CornerCommutators

  def initialize(results_model, letter)
    super(results_model)
    @letter = letter.downcase
  end

  def selector(pair)
    pair.letters.include?(@letter)
  end

end

class EdgeCommutators < Commutators

  VALID_PAIRS = EDGE_LETTER_PAIRS - FLIPS

  def badness_exponent
    6
  end
  
end
