# frozen_string_literal: true

require 'twisty_puzzles'

module CubeTrainer
  module CaseSetSetupFinder
    # Contains seed algs to start the search for a `CaseSetSetupFinder`.
    # This is just a list of list of algs, so it's long but not very complicated,
    # therefore we accept a very long module and very long methods.
    # rubocop:disable Metrics/ModuleLength
    # rubocop:disable Metrics/MethodLength
    module CaseSetSeedAlgs
      def case_set
        raise NotImplementedError
      end

      include TwistyPuzzles

      def initial_cased_algs
        seed_algs =
          case case_set
          when CaseSets::BufferedParitySet then buffered_parity_set_seed_algs
          when CaseSets::BufferedParityTwistSet then buffered_parity_twist_set_seed_algs
          when CaseSets::BufferedThreeCycleSet then buffered_three_cycle_seed_algs
          when CaseSets::BufferedThreeTwistSet then buffered_three_twist_seed_algs
          when CaseSets::ConcreteFloatingTwoTwistSet then floating_two_twist_seed_algs
          else
            raise "Unsupported case set class #{case_set.class}."
          end
        cased_seed_algs =
          seed_algs.map do |a|
            attach_case(a)
          end
        extend_cased_algorithms(cased_seed_algs)
      end

      def attach_case(algorithm)
        { casee: case_reverse_engineer.find_case(algorithm), algorithm: algorithm }
      end

      def extend_cased_algorithms_with_operation(cased_algorithms, &block)
        cased_algorithms + cased_algorithms.map { |a| a.transform_values(&block) }
      end

      # Turns a set of seed algorithms into a bigger set by
      # * mirrors
      # * inverses
      # * rotations
      # and combinations thereof.
      def extend_cased_algorithms(cased_algorithms)
        extended_algorithms = extend_cased_algorithms_with_operation(cased_algorithms) { |a| a.mirror(Face::U) }
        extended_algorithms = extend_cased_algorithms_with_operation(extended_algorithms, &:inverse)
        rotation_combos = Rotation::ALL_ROTATIONS.product(Rotation::ALL_ROTATIONS)
        extended_algorithms =
          rotation_combos.flat_map do |r, q|
            extend_cased_algorithms_with_operation(extended_algorithms) { |a| a.rotate_by(r).rotate_by(q) }
          end
        extended_algorithms.uniq
      end

      def extend_algorithms(seed_algorithms)
        extend_cased_algorithms(seed_algorithms.map { |a| { alg: a } }).pluck(:alg)
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

      def buffered_corner_three_cycle_algs
        [
          parse_algorithm("R U R' D R U' R' D'"),
          parse_algorithm("R U' R' D R U R' D'"),
          parse_algorithm("R U2 R' D R U2 R' D'"),
          parse_algorithm("R U R' D' R U' R' D"),
          parse_algorithm("R U' R' D' R U R' D"),
          parse_algorithm("R U2 R' D' R U2 R' D"),
          parse_algorithm("R U R' D2 R U' R' D2"),
          parse_algorithm("R U' R' D2 R U R' D2"),
          parse_algorithm("R U2 R' D2 R U2 R' D2")
        ]
      end

      def buffered_edge_three_cycle_algs
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
          parse_algorithm("R2 U' M2 U R2 U' M2 U")
        ]
      end

      def buffered_wing_three_cycle_algs
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
          parse_algorithm("R2 U' r2 U R2 U' r2 U")
        ]
      end

      def buffered_xcenter_three_cycle_algs
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
          parse_algorithm("r u2 r' D2 r u2 r' D2")
        ]
      end

      def buffered_tcenter_three_cycle_algs
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
          parse_algorithm("r2 U' M2 U r2 U' M2 U")
        ]
      end

      def buffered_three_cycle_seed_algs
        part_type = case_set.part_type
        if part_type == Corner
          buffered_corner_three_cycle_algs
        elsif [Edge, Midge].include?(part_type)
          buffered_edge_three_cycle_algs
        elsif part_type == Wing
          buffered_wing_three_cycle_algs
        elsif part_type == XCenter
          buffered_xcenter_three_cycle_algs
        elsif part_type == TCenter
          buffered_tcenter_three_cycle_algs
        else
          raise "Unsupported part type set class #{part_type} for buffered three cycles."
        end
      end

      def buffered_three_twist_seed_algs
        [
          parse_algorithm("R' D R D' R' D R D' U R' D R D' R' D R D' U R' D R D' R' D R D' U2")
        ]
      end

      def floating_two_twist_seed_algs
        part_type = case_set.part_type
        if part_type == Corner
          [
            parse_algorithm("R' D R D' R' D R U R' D' R D R' D' R U'"),
            parse_algorithm("R' D R D' R' D R U2 R' D' R D R' D' R U2")
          ]
        elsif [Edge, Midge].include?(part_type)
          [
            parse_algorithm("R' E R U' R' E' R2 E2 R' U R E2 R'"),
            parse_algorithm("R' E R U R' E' R2 E2 R' U' R E2 R'")
          ]
        else
          raise "Unsupported part type set class #{part_type.class} for floating two twists."
        end
      end

      def only_thin_moves
        [parse_move('R')]
      end

      def thin_and_fat_moves
        [parse_move('R'), parse_move('Rw')]
      end

      def setup_algs
        setup_moves =
          case case_set
          when CaseSets::BufferedParitySet, CaseSets::BufferedParityTwistSet
            thin_and_fat_moves
          when CaseSets::BufferedThreeCycleSet, CaseSets::ConcreteFloatingTwoTwistSet
            if case_set.part_type == Corner
              only_thin_moves
            else
              thin_and_fat_moves
            end
          when CaseSets::BufferedThreeTwistSet then only_thin_moves
          else
            raise "Unsupported case set class #{case_set.class}."
          end
        extend_algorithms(setup_moves.map { |m| Algorithm.move(m) })
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/ModuleLength
  end
end
