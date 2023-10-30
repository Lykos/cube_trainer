require 'twisty_puzzles'

module CubeTrainer
  class CaseSetSetupFinder
    def initialize(concrete_case_set)
      raise TypeError unless concrete_case_set.is_a?(ConcreteCaseSet)

      @concrete_case_set = concrete_case_set
    end

    def find_setup(casee)
      raise ArgumentError unless casee.valid?
      raise ArgumentError unless @concrete_case_set.case_set.match?(casee)

      setup_hash[casee]
    end

    private

    include TwistyPuzzles

    def initial_algs
      seed_algs =
        case @concrete_case_set
        when BufferedParitySet then buffered_parity_set_seed_algs
        when BufferedParityTwistSet then buffered_parity_twist_set_seed_algs
        when BufferedThreeCycleSet then buffered_three_cycle_seed_algs
        when BufferedThreeTwistSet then buffered_three_twist_seed_algs
        when ConcreteFloatingTwoTwistSet then floating_two_twist_seed_algs
        else
          raise 'Unsupported case set class #{@concrete_case_set.class}.'
        end
      extend_algorithms(seed_algs)
    end

    # Turns a set of seed algorithms into a bigger set by
    # * mirrors
    # * inverses
    # * rotations
    # and combinations thereof.
    def extend_algorithms(seed_algorithms)
      extended_algorithms = algorithms.flat_map { |a| [a, a.mirror(Face::U)] }
      extended_algorithms = algorithms.flat_map { |a| [a, a.inverse] }
      rotation_combos = Rotation::ALL_ROTATIONS.product(Rotation::ALL_ROTATIONS)
      extended_algorithms = rotation_combos.flat_map { |r, q| mirror_extended_algorithms.map { |a| a.rotate_by(r).rotate_by(q) } }
      extended_algorithms.uniq
    end

    def buffered_parity_set_seed_algs
      [
        parse_algorithm("Fw2 R D R' Fw2 R D' R D R2"),
        parse_algorithm("Rw' U Rw' U2 R B' R' U2 Rw2 B'"),
        parse_algorithm("R U2 R' U' R U2 L' U R' U' L"),
        parse_algorithm("R2 D B2 D' Fw2 D B2 D' Fw2 R2 U'"),
        parse_algorithm("R2 Uw R2 Uw' R2 F2 Uw' F2 Uw F2 U'"),
        parse_algorithm("R' U R U2 L' R' U R U' L U2")
      ]
    end

    def buffered_parity_twist_set_seed_algs
      [
        parse_algorithm("R U2 R D Rw' U2 Rw D' R2 U")
      ]
    end

    def buffered_three_cycle_seed_algs
      case @concrete_case_set.part_type
      when Corner
        [
          parse_algorithm("R U R' D R U' R' D'"),
          parse_algorithm("R U' R' D R U R' D'"),
          parse_algorithm("R U2 R' D R U2 R' D'"),
          parse_algorithm("R U R' D' R U' R' D"),
          parse_algorithm("R U' R' D' R U R' D"),
          parse_algorithm("R U2 R' D' R U2 R' D"),
          parse_algorithm("R U R' D2 R U' R' D2"),
          parse_algorithm("R U' R' D2 R U R' D2"),
          parse_algorithm("R U2 R' D2 R U2 R' D2"),
        ]
      when Edge, Midge
        [
          parse_algorithm("M' U2 M U2"),
          parse_algorithm("U M' U2 M U"),
          parse_algorithm("M' U2 M D M' U2 M D'"),
          parse_algorithm("M' U' R U M U' R' U"),
          parse_algorithm("M' U' R' U M U' R U"),
          parse_algorithm("M' U' R2 U M U' R2 U"),
          parse_algorithm("M U' R U M' U' R' U"),
          parse_algorithm("M U' R' U M' U' R U"),
          parse_algorithm("M U' R2 U M' U' R2 U"),
          parse_algorithm("M2 U' R U M2 U' R' U"),
          parse_algorithm("M2 U' R' U M2 U' R U"),
          parse_algorithm("M2 U' R2 U M2 U' R2 U"),
          parse_algorithm("R' U' M U R U' M' U"),
          parse_algorithm("R' U' M' U R U' M U"),
          parse_algorithm("R' U' M2 U R U' M2 U"),
          parse_algorithm("R U' M U R' U' M' U"),
          parse_algorithm("R U' M' U R' U' M U"),
          parse_algorithm("R U' M2 U R' U' M2 U"),
          parse_algorithm("R2 U' M U R2 U' M' U"),
          parse_algorithm("R2 U' M' U R2 U' M U"),
          parse_algorithm("R2 U' M2 U R2 U' M2 U"),
        ]
      when Wing
        [
          parse_algorithm("r' U' R U r U' R' U"),
          parse_algorithm("r' U' R' U r U' R U"),
          parse_algorithm("r' U' R2 U r U' R2 U"),
          parse_algorithm("r U' R U r' U' R' U"),
          parse_algorithm("r U' R' U r' U' R U"),
          parse_algorithm("r U' R2 U r' U' R2 U"),
          parse_algorithm("r2 U' R U r2 U' R' U"),
          parse_algorithm("r2 U' R' U r2 U' R U"),
          parse_algorithm("r2 U' R2 U r2 U' R2 U"),
          parse_algorithm("R' U' r U R U' r' U"),
          parse_algorithm("R' U' r' U R U' r U"),
          parse_algorithm("R' U' r2 U R U' r2 U"),
          parse_algorithm("R U' r U R' U' r' U"),
          parse_algorithm("R U' r' U R' U' r U"),
          parse_algorithm("R U' r2 U R' U' r2 U"),
          parse_algorithm("R2 U' r U R2 U' r' U"),
          parse_algorithm("R2 U' r' U R2 U' r U"),
          parse_algorithm("R2 U' r2 U R2 U' r2 U"),
        ]
      when XCenter
        [
          parse_algorithm("r U r' d r U' r' d'"),
          parse_algorithm("r U' r' d r U r' d'"),
          parse_algorithm("r U2 r' d r U2 r' d'"),
          parse_algorithm("r U r' d' r U' r' d"),
          parse_algorithm("r U' r' d' r U r' d"),
          parse_algorithm("r U2 r' d' r U2 r' d"),
          parse_algorithm("r U r' d2 r U' r' d2"),
          parse_algorithm("r U' r' d2 r U r' d2"),
          parse_algorithm("r U2 r' d2 r U2 r' d2"),
          parse_algorithm("r u r' D r u' r' D'"),
          parse_algorithm("r u' r' D r u r' D'"),
          parse_algorithm("r u2 r' D r u2 r' D'"),
          parse_algorithm("r u r' D' r u' r' D"),
          parse_algorithm("r u' r' D' r u r' D"),
          parse_algorithm("r u2 r' D' r u2 r' D"),
          parse_algorithm("r u r' D2 r u' r' D2"),
          parse_algorithm("r u' r' D2 r u r' D2"),
          parse_algorithm("r u2 r' D2 r u2 r' D2"),
        ]        
      when TCenter
        [
          parse_algorithm("M' U2 M D M' U2 M D'"),
          parse_algorithm("M' U' r U M U' r' U"),
          parse_algorithm("M' U' r' U M U' r U"),
          parse_algorithm("M' U' r2 U M U' r2 U"),
          parse_algorithm("M U' r U M' U' r' U"),
          parse_algorithm("M U' r' U M' U' r U"),
          parse_algorithm("M U' r2 U M' U' r2 U"),
          parse_algorithm("M2 U' r U M2 U' r' U"),
          parse_algorithm("M2 U' r' U M2 U' r U"),
          parse_algorithm("M2 U' r2 U M2 U' r2 U"),
          parse_algorithm("r' U' M U r U' M' U"),
          parse_algorithm("r' U' M' U r U' M U"),
          parse_algorithm("r' U' M2 U r U' M2 U"),
          parse_algorithm("r U' M U r' U' M' U"),
          parse_algorithm("r U' M' U r' U' M U"),
          parse_algorithm("r U' M2 U r' U' M2 U"),
          parse_algorithm("r2 U' M U r2 U' M' U"),
          parse_algorithm("r2 U' M' U r2 U' M U"),
          parse_algorithm("r2 U' M2 U r2 U' M2 U"),
        ]
      else
        raise 'Unsupported part type set class #{@concrete_case_set.part_type.class}.'
      end
    end

    def buffered_three_twist_seed_algs
      [
        parse_algorithm("R' D R D' R' D R D' U R' D R D' R' D R D' U R' D R D' R' D R D' U2")
      ]
    end

    def buffered_floating_two_twist_seed_algs
      [
        parse_algorithm("R' D R D' R' D R U R' D' R D R' D' R U'"),
        parse_algorithm("R' D R D' R' D R U2 R' D' R D R' D' R U2")
      ]
    end

    def setup_algs
      setup_moves =
        case @concrete_case_set
        when BufferedParitySet then [parse_move('R')]
        when BufferedParityTwistSet then [parse_move('R')]
        when BufferedThreeCycleSet then [parse_move('R'), parse_move('Rw')]
        when BufferedThreeTwistSet then [parse_move('R')]
        when ConcreteFloatingTwoTwistSet then [parse_move('R')]
        else
          raise 'Unsupported case set class #{@concrete_case_set.class}.'
        end
      extend_algorithms(setup_moves.map { |m| Algorithm.move(m) })
    end

    def case_reverse_engineer
      @case_reverse_engineer ||=
        CubeTrainer::CaseReverseEngineer.new(
          cube_size: owning_set.case_set.default_cube_size
        )
    end

    def create_setup_hash
      setup_hash = {}
      cases = case_set.cases
      algs = initial_algs

      loop do
        algs.each do |alg|
          casee = case_reverse_engineer.find_case(alg)

          found_cases = cases.select { |c| c.equivalent?(casee) }
          found_cases.each { |c| setup_hash[c] = alg }
          cases -= found_cases
        end
        break if cases.empty?

        algs = algs.flat_map { |alg| setup_algs.flat_map { |s| s + alg + s.inverse } }
      end
    end

    def setup_hash
      @setup_map ||= create_setup_hash
    end
  end
end
