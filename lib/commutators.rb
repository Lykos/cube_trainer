require 'letter_pair_helper'
require 'sampling_helper'

class Commutators
  
  include SamplingHelper
  include LetterPairHelper

  # If restrict_letters is not nil, only commutators for those letters are used.
  def initialize(results_model, restrict_letters=nil)
    @results_model = results_model
    @restrict_letters = restrict_letters
  end
  
  def results
    @results_model.results
  end

  def selectable_pairs
    @selectable_pairs ||= self.class::VALID_PAIRS.select do |p|
      @restrict_letters.nil? || !(p.letters & @restrict_letters).empty?
    end
  end

  def random_letter_pair
    random_input(selectable_pairs, results)
  end
  
end

class CornerCommutators < Commutators
  
  VALID_PAIRS = CORNER_LETTER_PAIRS - TWISTS

  def goal_badness
    1.5
  end
  
end

class EdgeCommutators < Commutators

  VALID_PAIRS = EDGE_LETTER_PAIRS - FLIPS

  def goal_badness
    1.0
  end
  
end

class WingCommutators < Commutators

  VALID_PAIRS = EDGE_LETTER_PAIRS

  def goal_badness
    2.0
  end
  
end

class XCenterCommutators < Commutators

  VALID_PAIRS = XCENTER_LETTER_PAIRS - XCENTER_NEIGHBORS

  def goal_badness
    2.0
  end
  
end

class TCenterCommutators < Commutators

  VALID_PAIRS = TCENTER_LETTER_PAIRS - TCENTER_NEIGHBORS

  def goal_badness
    2.0
  end
  
end
