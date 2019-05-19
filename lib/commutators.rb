require 'letter_pair_helper'
require 'input_sampler'
require 'hint_parser'

module CubeTrainer

  class Commutators
    
    include LetterPairHelper
  
    # If restrict_letters is not nil, only commutators for those letters are used.
    def initialize(results_model, options, buffer)
      raise ArgumentError, "Buffer has an invalid type." unless buffer.class == part_type
      @buffer = buffer
      @letter_scheme = options.letter_scheme
      pieces = if options.restrict_letters and not options.restrict_letters.empty?
                 valid_pairs.select { |p| p.letters.any? { |l| options.restrict_letters.include?(l) } }
               else
                 valid_pairs
               end
      @input_sampler = InputSampler.new(pieces, results_model, goal_badness, options.verbose, options.new_item_boundary)
      @hinter = Hinter.maybe_create(part_type, buffer, options)
    end
  
    attr_reader :hinter, :input_sampler, :buffer, :letter_scheme
  
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
