require 'letter_pair_helper'
require 'input_sampler'
require 'hint_parser'

module CubeTrainer

  class Commutators
    
    include LetterPairHelper
  
    # If restrict_letters is not nil, only commutators for those letters are used.
    def initialize(results_model, options, buffer)
      @buffer = buffer
      pieces = valid_pairs.select { |p| p.letters.any? { |l| options.restrict_letters.include?(l) } }
      @input_sampler = InputSampler.new(pieces, results_model, goal_badness, options.verbose, options.new_item_boundary)
      @hinter = HintParser.maybe_create(self.class::PIECE_TYPE, options.cube_size, options.test_comms)
    end
  
    attr_reader :hinter, :input_sampler
    attr_reader :buffer
  
  end
  
  class CornerCommutators < Commutators

    def part_type
      Corner
    end

    def valid_pairs
      @valid_pairs ||= letter_pairs - rotations
    end
  
    def goal_badness
      1.5
    end
    
  end
  
  class EdgeCommutators < Commutators
  
    def part_type
      Edge
    end

    def valid_pairs
      @valid_pairs ||= letter_pairs - rotations
    end
  
    def goal_badness
      1.0
    end
    
  end
  
  class WingCommutators < Commutators
  
    def part_type
      Wing
    end

    def valid_pairs
      @valid_pairs ||= letter_pairs - rotations
    end
  
    def goal_badness
      2.0
    end
    
  end
  
  class XCenterCommutators < Commutators
  
    def part_type
      XCenter
    end

    def valid_pairs
      @valid_pairs ||= letter_pairs - neighbors
    end
    
    def goal_badness
      4.0
    end
    
  end
  
  class TCenterCommutators < Commutators
  
    def part_type
      TCenter
    end

    def valid_pairs
      @valid_pairs ||= letter_pairs - neighbors
    end
    
    def goal_badness
      4.0
    end
    
  end

end
