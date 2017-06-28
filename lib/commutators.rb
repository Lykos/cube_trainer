require 'letter_pair_helper'
require 'sampling_helper'

class CornerCommutators
  
  include SamplingHelper
  include LetterPairHelper
  
  VALID_PAIRS = LETTER_PAIRS - TWISTS

  def initialize(results_model)
    @results_model = results_model
  end

  def results
    @results_model.results
  end

  def random_letter_pair
    random_input(VALID_PAIRS, results)
  end
  
end
