require 'letter_pair_helper'
require 'input_sampler'
require 'hint_parser'
require 'letter_pair_sequence'
require 'utils'
require 'sequence_hinter'
require 'letter_pair_alg_set'

module CubeTrainer

  ORIENTATION_FACES = [Face.by_name('U'), Face.by_name('D')]

  def orientation_face(part)
    faces = ORIENTATION_FACES.select { |f| part.colors.include?(f.color) }
    raise "Couldn't determine unique orientation face for #{part}: #{faces}" unless faces.length == 1
    faces.first
  end

  def rotate_orientation_face_up(part)
    part.rotate_face_up(orientation_face(part))
  end

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

    def generate_letter_pairs
      non_buffer_corners = PART_TYPE::ELEMENTS.select { |c| !c.turned_equals?(buffer) }
      correctly_oriented_corners = non_buffer_corners.select { |c| ORIENTATION_FACES.include?(c.solved_face) }
      twisted_corner_pairs = correctly_oriented_corners.permutation(2).map { |c1, c2| [c1.rotate_by(1), c2.rotate_by(2)] }
      two_twists = twisted_corner_pairs.map { |cs| LetterPair.new(cs.map { |c| letter_scheme.letter(c) }) }
      one_twists = twisted_corner_pairs.flatten.map { |c| LetterPair.new([letter_scheme.letter(c)]) }.uniq
      two_twists + one_twists
    end
 
  end

  class CornerTwistsPlusParities < LetterPairAlgSet
    PART_TYPE = Corner

    def initialize(result_model, options)
      super
      corner_options = options.dup
      corner_options.commutator_info = Options::COMMUTATOR_TYPES['corners'] || raise
      corner_options.picture = false
      corner_results = result_model.result_persistence.load_results(BufferHelper.mode_for_options(corner_options))
      corner_hinter = Hinter.maybe_create(PART_TYPE, corner_options)

      parity_options = options.dup
      parity_options.commutator_info = Options::COMMUTATOR_TYPES['corner_parities'] || raise
      corner_options.picture = false
      parity_results = result_model.result_persistence.load_results(BufferHelper.mode_for_options(parity_options))
      parity_hinter = Hinter.maybe_create(PART_TYPE, parity_options)

      @hinter = CornerTwistPlusParityHinter.new(corner_results, parity_results, corner_hinter, parity_hinter, options)
    end

    attr_reader :hinter
    
    def goal_badness
      2.0
    end

    def generate_letter_pairs
      non_buffer_corners = PART_TYPE::ELEMENTS.select { |c| !c.turned_equals?(buffer) }
      incorrectly_oriented_corners = non_buffer_corners.select { |c| !ORIENTATION_FACES.include?(c.solved_face) }
      non_buffer_corners.product(incorrectly_oriented_corners).select do |parity, twist|
        !parity.turned_equals?(twist)
      end.map do |targets|
        LetterPairSequence.new(targets.map { |t| LetterPair.new([letter_scheme.letter(t)]) })
      end
    end

    class CornerTwistPlusParityHinter < HeterogenousSequenceHinter
      def initialize(corner_results, parity_results, corner_hinter, parity_hinter, options)
        super([corner_results, parity_results], [corner_hinter, parity_hinter])
        @letter_scheme = options.letter_scheme
      end

      def generate_combinations(letter_sequence)
        raise ArgumentError unless letter_sequence.letter_pairs.length == 2
        parity_letter_pair = letter_sequence.letter_pairs.first
        parity_letter = only(parity_letter_pair.letters)
        twist_letter_pair = letter_sequence.letter_pairs.last
        twist_letter = only(twist_letter_pair.letters)
        twisted_part = @letter_scheme.for_letter(PART_TYPE, twist_letter)
        solved_twist_part = rotate_orientation_face_up(twisted_part)
        Corner::FACES.times.map do |rot|
          twist_entry_letter = @letter_scheme.letter(twisted_part.rotate_by(rot))
          twist_exit_letter = @letter_scheme.letter(solved_twist_part.rotate_by(rot))
          comm = LetterPair.new([parity_letter, twist_entry_letter])
          parity = LetterPair.new([twist_exit_letter])
          [comm, parity]
        end
      end
    end
  end

  class Corner3Twists < LetterPairAlgSet
    PART_TYPE = Corner

    def initialize(result_model, options)
      super
      corner_options = options.dup
      corner_options.commutator_info = Options::COMMUTATOR_TYPES['corners'] || raise
      corner_options.picture = false
      corner_results = result_model.result_persistence.load_results(BufferHelper.mode_for_options(corner_options))
      corner_hinter = Hinter.maybe_create(PART_TYPE, corner_options)
      @hinter = Corner3TwistHinter.new(corner_results, corner_hinter, options)
    end

    attr_reader :hinter
    
    def goal_badness
      2.0
    end

    def generate_input_items
      cube_state = CubeState.solved(options.cube_size)
      non_buffer_corners = PART_TYPE::ELEMENTS.select { |c| !c.turned_equals?(buffer) }
      correctly_oriented_corners = non_buffer_corners.select { |c| ORIENTATION_FACES.include?(c.solved_face) }
      1.upto(2).collect_concat do |twist_number|
        cube_state.rotate_piece(buffer)
        correctly_oriented_corners.combination(2).collect_concat do |c1, c2|
          twist_number.times do
            cube_state.rotate_piece(c1)
            cube_state.rotate_piece(c2)
          end
          twisted_corner_pair = [c1.rotate_by(twist_number), c2.rotate_by(twist_number)]
          letter_pair = LetterPair.new(twisted_corner_pair.map { |c| letter_scheme.letter(c) }.sort)
          twisted_cube_state = cube_state.dup
          (3 - twist_number).times do
            cube_state.rotate_piece(c1)
            cube_state.rotate_piece(c2)
          end
          InputItem.new(letter_pair, twisted_cube_state)
        end
      end
    end
 
    class Corner3TwistHinter < HomogenousSequenceHinter
      # Note that this should be the results for corner comms, not for corner 3 twists.
      def initialize(corner_results, corner_hinter, options)
        super(corner_results, corner_hinter)
        @letter_scheme = options.letter_scheme
      end

      def rotate_other_face_up(part)
        part.rotate_other_face_up(orientation_face(part))
      end

      def rotate_comm_target(comm, target_index, rotation)
        raise ArgumentError unless comm.length == 2
        raise ArgumentError unless [0, 1].include?(target_index)
        comm.map.with_index do |c, i|
          if i == target_index
            c.rotate_by(rotation)
          else
            c
          end
        end
      end

      def generate_directed_solutions(parts)
        raise unless parts.length == 2
        first_corner, second_corner = parts

        # We define one solution explicitly
        solution_corners = [
          # Parts for first comm
          [first_corner, second_corner],
          # Parts for second comm
          [rotate_orientation_face_up(second_corner), rotate_other_face_up(first_corner)]
        ]

        # Now we generate additional solutions by rotating both colors in one direction.
        extended_solutions = Corner::FACES.times.collect do |rot|
          solution_corners.map do |comm|
            comm.map { |p| p.rotate_by(rot) }
          end
        end

        # Now we generate even more additional solutions by rotating the second corner of the first
        # comm and the first corner of the second comm in opposite directions.
        extended_solutions = Corner::FACES.times.collect_concat do |rot|
          extended_solutions.map do |solution|
            raise unless solution.length == 2
            first_comm, second_comm = solution
            [rotate_comm_target(first_comm, 1, rot),
             rotate_comm_target(second_comm, 0, rot)]
          end
        end

        # Now we generate letter pairs
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
      1.0
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

  class CornerParities < LetterPairAlgSet
    
    PART_TYPE = Corner

    def initialize(result_model, options)
      super
      @hinter = NoHinter.new
    end

    attr_reader :hinter
    
    def goal_badness
      2.0
    end

    def generate_letter_pairs
      non_buffer_corners = PART_TYPE::ELEMENTS.select { |c| !c.turned_equals?(buffer) }
      non_buffer_corners.map { |c| LetterPair.new([letter_scheme.letter(c)]) }
    end
    
  end

end
