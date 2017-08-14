require 'letter_pair_helper'
require 'sampling_helper'

class Commutators
  
  include SamplingHelper
  include LetterPairHelper
  
  def initialize(results_model)
    @results_model = results_model
  end

  def results
    @results_model.results
  end

  def random_letter_pair
    random_input(self.class::VALID_PAIRS, results)
  end
  
end

class CornerCommutators < Commutators
  
  VALID_PAIRS = CORNER_LETTER_PAIRS - TWISTS

end

class EdgeCommutators < Commutators

  VALID_PAIRS = EDGE_LETTER_PAIRS - FLIPS
  
end
