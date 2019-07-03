require 'letter_pair_helper'
require 'input_sampler'
require 'hint_parser'

module CubeTrainer

  class LetterPairAlgSet

    include LetterPairHelper
  
    def initialize(results_model, options)
      @letter_scheme = options.letter_scheme
      pieces = if options.restrict_letters and not options.restrict_letters.empty?
                 valid_pairs.select { |p| p.letters.any? { |l| options.restrict_letters.include?(l) } }
               else
                 valid_pairs
               end
      @input_sampler = InputSampler.new(pieces, results_model, goal_badness, options.verbose, options.new_item_boundary)
    end

    attr_reader :input_sampler, :letter_scheme

    def part_type
      raise NotImplementedError
    end

    def goal_badness
      raise NotImplementedError
    end
    
    def valid_pairs
      raise NotImplementedError
    end

    def hinter
      raise NotImplementedError
    end
  end

  class FloatingCornerTwists < LetterPairAlgSet
    def initialize(result_model, options, buffer)
      super(result_model, options)
      @hinter = NoHinter.new
      raise "Floating corner twists shouldn't have a buffer." if buffer
    end

    def goal_badness
      1.0
    end

    def part_type
      Corner
    end

    ORIENTATION_FACES = [Face.by_name('U'), Face.by_name('D')]

    def valid_pairs
      correctly_oriented_corners = part_type::ELEMENTS.select { |c| ORIENTATION_FACES.include?(c.solved_face) }
      twisted_corner_pairs = correctly_oriented_corners.permutation(2).map { |c1, c2| [c1.rotate_by(1), c2.rotate_by(2)] }
      twisted_corner_pairs.map { |cs| LetterPair.new(cs.map { |c| letter_scheme.letter(c) }) }
    end

    attr_reader :hinter
  end

  class Commutators < LetterPairAlgSet
    
    # If restrict_letters is not nil, only commutators for those letters are used.
    def initialize(results_model, options, buffer)
      raise ArgumentError, "Buffer has an invalid type." unless buffer.class == part_type
      @buffer = buffer
      super(results_model, options)
      @hinter = Hinter.maybe_create(part_type, buffer, options)
    end
  
    attr_reader :hinter, :buffer
  
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
