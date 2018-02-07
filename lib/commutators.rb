require 'letter_pair_helper'
require 'input_sampler'
require 'hint_parser'

module CubeTrainer

  class Commutators
    
    include LetterPairHelper
  
    # If restrict_letters is not nil, only commutators for those letters are used.
    def initialize(results_model, options)
      @input_sampler = InputSampler.new(self.class::VALID_PAIRS, results_model, goal_badness, options.verbose, options.new_item_boundary)
      @hinter = HintParser.maybe_create(self.class::PIECE_TYPE, options.cube_size, options.test_comms)
    end
  
    attr_reader :hinter, :input_sampler
  
  end
  
  class CornerCommutators < Commutators
  
    PIECE_TYPE = Corner
    VALID_PAIRS = CORNER_LETTER_PAIRS - TWISTS
  
    def goal_badness
      1.5
    end
    
  end
  
  class EdgeCommutators < Commutators
  
    PIECE_TYPE = Edge
    VALID_PAIRS = EDGE_LETTER_PAIRS - FLIPS
  
    def goal_badness
      1.0
    end
    
  end
  
  class WingCommutators < Commutators
  
    PIECE_TYPE = Wing
    VALID_PAIRS = WING_LETTER_PAIRS
  
    def goal_badness
      2.0
    end
    
  end
  
  class XCenterCommutators < Commutators
  
    PIECE_TYPE = XCenter
    VALID_PAIRS = XCENTER_LETTER_PAIRS - XCENTER_NEIGHBORS
  
    def goal_badness
      4.0
    end
    
  end
  
  class TCenterCommutators < Commutators
  
    PIECE_TYPE = TCenter
    VALID_PAIRS = TCENTER_LETTER_PAIRS - TCENTER_NEIGHBORS
  
    def goal_badness
      4.0
    end
    
  end

end
