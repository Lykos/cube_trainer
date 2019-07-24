require 'letter_pair_helper'
require 'input_sampler'
require 'hint_parser'
require 'letter_pair_alg_set'

module CubeTrainer

  class FloatingCornerTwists < LetterPairAlgSet
    PART_TYPE = Corner

    def initialize(result_model, options)
      super
      @hinter = NoHinter.new
    end

    attr_reader :hinter
    
    def goal_badness
      1.5
    end

    ORIENTATION_FACES = [Face.by_name('U'), Face.by_name('D')]

    def generate_letter_pairs
      non_buffer_corners = part_type::ELEMENTS.select { |c| !c.turned_equals?(buffer) }
      correctly_oriented_corners = non_buffer_corners.select { |c| ORIENTATION_FACES.include?(c.solved_face) }
      twisted_corner_pairs = correctly_oriented_corners.permutation(2).map { |c1, c2| [c1.rotate_by(1), c2.rotate_by(2)] }
      two_twists = twisted_corner_pairs.map { |cs| LetterPair.new(cs.map { |c| letter_scheme.letter(c) }) }
      one_twists = twisted_corner_pairs.flatten.map { |c| LetterPair.new([letter_scheme.letter(c)]) }.uniq
      two_twists + one_twists
    end
 
  end

  class FloatingEdgeFlips < LetterPairAlgSet
    PART_TYPE = Edge

    def initialize(result_model, options)
      super
      @hinter = NoHinter.new
    end

    attr_reader :hinter
    
    def goal_badness
      2.0
    end

    def generate_letter_pairs
      edge_letters = part_type::ELEMENTS.map { |c| c.rotations.map { |r| letter_scheme.letter(r) }.min }.uniq.sort
      edge_letters.combination(2).map { |cs| LetterPair.new(cs) }
    end
 
  end

  class Commutators < LetterPairAlgSet
    
    # If restrict_letters is not nil, only commutators for those letters are used.
    def initialize(results_model, options)
      super
      @hinter = Hinter.maybe_create(self.class::PART_TYPE, options)
    end
  
    attr_reader :hinter
  
  end
  
  class CornerCommutators < Commutators

    PART_TYPE = Corner

    def generate_letter_pairs
      letter_pairs_for_piece - rotations
    end
  
    def goal_badness
      1.5
    end
    
  end
  
  class EdgeCommutators < Commutators
  
    PART_TYPE = Edge

    def generate_letter_pairs
      letter_pairs_for_piece - rotations
    end
  
    def goal_badness
      1.0
    end
    
  end
  
  class WingCommutators < Commutators
  
    PART_TYPE = Wing

    def generate_letter_pairs
      letter_pairs_for_piece - rotations
    end
  
    def goal_badness
      2.0
    end
    
  end
  
  class XCenterCommutators < Commutators
  
    PART_TYPE = XCenter

    def generate_letter_pairs
      letter_pairs_for_piece - neighbors
    end
    
    def goal_badness
      4.0
    end
    
  end
  
  class TCenterCommutators < Commutators
  
    PART_TYPE = TCenter

    def generate_letter_pairs
      letter_pairs_for_piece - neighbors
    end
    
    def goal_badness
      4.0
    end
    
  end

end
