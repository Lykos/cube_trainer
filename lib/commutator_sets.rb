require 'letter_pair_helper'
require 'input_sampler'
require 'hint_parser'
require 'combination_based_hinter'
require 'letter_pair_alg_set'

module CubeTrainer

  class FloatingCorner2Twists < LetterPairAlgSet
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
      non_buffer_corners = PART_TYPE::ELEMENTS.select { |c| !c.turned_equals?(buffer) }
      correctly_oriented_corners = non_buffer_corners.select { |c| ORIENTATION_FACES.include?(c.solved_face) }
      twisted_corner_pairs = correctly_oriented_corners.permutation(2).map { |c1, c2| [c1.rotate_by(1), c2.rotate_by(2)] }
      two_twists = twisted_corner_pairs.map { |cs| LetterPair.new(cs.map { |c| letter_scheme.letter(c) }) }
      one_twists = twisted_corner_pairs.flatten.map { |c| LetterPair.new([letter_scheme.letter(c)]) }.uniq
      two_twists + one_twists
    end
 
  end

  class Corner3Twists < LetterPairAlgSet
    PART_TYPE = Corner

    def initialize(result_model, options)
      super
      corner_options = options.dup
      corner_options.commutator_info = Options::COMMUTATOR_TYPES['corners'] || raise
      corner_results = result_model.result_persistence.load_results(BufferHelper.mode_for_buffer(corner_options))
      @hinter = Corner3TwistHinter.new(corner_results, options)
    end

    attr_reader :hinter
    
    def goal_badness
      1.5
    end

    ORIENTATION_FACES = [Face.by_name('U'), Face.by_name('D')]

    def generate_letter_pairs
      non_buffer_corners = PART_TYPE::ELEMENTS.select { |c| !c.turned_equals?(buffer) }
      correctly_oriented_corners = non_buffer_corners.select { |c| ORIENTATION_FACES.include?(c.solved_face) }
      1.upto(2).collect_concat do |twist_number|
        correctly_oriented_corners.permutation(2).collect_concat do |c1, c2|
          twisted_corner_pair = [c1.rotate_by(twist_number), c2.rotate_by(twist_number)]
          LetterPair.new(twisted_corner_pair.map { |c| letter_scheme.letter(c) })
        end
      end

    end
 
    class Corner3TwistHinter < CombinationBasedHinter

      # Note that this should be the results for corner comms, not for corner 3 twists.
      def initialize(corner_results, options)
        super(corner_results)
        @letter_scheme = options.letter_scheme
      end

      def orientation_face(part)
        faces = ORIENTATION_FACES.select { |f| part.colors.include?(f.color) }
        raise "Couldn't determine unique orientation face for #{part}: #{faces}" unless faces.length == 1
        faces.first
      end

      def rotate_orientation_face_up(part)
        part.rotate_face_up(orientation_face(part))
      end

      def rotate_other_face_up(part)
        part.rotate_other_face_up(orientation_face(part))
      end

      def generate_directed_solutions(parts)
        raise unless parts.length == 2
        first_part, second_part = parts
        solution_parts = [
          # Parts for first comm
          [first_part, second_part],
          # Parts for second comm
          [rotate_orientation_face_up(second_part), rotate_other_face_up(first_part)]
        ]
        extended_solutions = 0.upto(2).collect { |rot| solution_parts.map { |comm| comm.map { |p| p.rotate_by(rot) } } }
        extended_solutions.map { |s| s.map { |comm| LetterPair.new(comm.map { |p| @letter_scheme.letter(p) }) } }
      end

      def generate_combinations(letter_pair)
        pieces = letter_pair.letters.map { |l| @letter_scheme.for_letter(PART_TYPE, l) }
        generate_directed_solutions(pieces) + generate_directed_solutions(pieces.reverse)
      end
    
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
      edge_letters = PART_TYPE::ELEMENTS.map { |c| c.rotations.map { |r| letter_scheme.letter(r) }.min }.uniq.sort
      edge_letters.combination(2).map { |cs| LetterPair.new(cs) }
    end
 
  end

  class CommutatorSet < LetterPairAlgSet
    
    # If restrict_letters is not nil, only commutators for those letters are used.
    def initialize(results_model, options)
      super
      @hinter = Hinter.maybe_create(self.class::PART_TYPE, options)
    end
  
    attr_reader :hinter
  
  end
  
  class CornerCommutators < CommutatorSet

    PART_TYPE = Corner

    def generate_letter_pairs
      letter_pairs_for_piece - rotations
    end
  
    def goal_badness
      1.5
    end
    
  end
  
  class EdgeCommutators < CommutatorSet
  
    PART_TYPE = Edge

    def generate_letter_pairs
      letter_pairs_for_piece - rotations
    end
  
    def goal_badness
      1.0
    end
    
  end
  
  class WingCommutators < CommutatorSet
  
    PART_TYPE = Wing

    def generate_letter_pairs
      letter_pairs_for_piece - rotations
    end
  
    def goal_badness
      2.0
    end
    
  end
  
  class XCenterCommutators < CommutatorSet
  
    PART_TYPE = XCenter

    def generate_letter_pairs
      letter_pairs_for_piece - neighbors
    end
    
    def goal_badness
      4.0
    end
    
  end
  
  class TCenterCommutators < CommutatorSet
  
    PART_TYPE = TCenter

    def generate_letter_pairs
      letter_pairs_for_piece - neighbors
    end
    
    def goal_badness
      4.0
    end
    
  end

end
