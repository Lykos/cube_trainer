# frozen_string_literal: true

module CubeTrainer
  # Some helper functions to modify broken algorithms to try to fix them.
  module AlgModificationsHelper
    def move_modifications(move)
      mirror = move.mirror(move.axis_face)
      [move, move.inverse, mirror, mirror.inverse].uniq
    end

    def permutation_modifications(alg)
      if alg.length <= 3
        alg.moves.permutation.map { |p| TwistyPuzzles::Algorithm.new(p) }
      else
        [alg]
      end
    end

    def algs_with_replaced_move(alg, move_index, moves)
      alg_moves = alg.moves.dup
      moves.map do |move|
        alg_moves[move_index] = move
        TwistyPuzzles::Algorithm.new(alg_moves)
      end
    end

    def alg_modifications(alg)
      perms = permutation_modifications(alg)
      algs =
        alg.moves.flat_map.with_index do |m, i|
          algs_with_replaced_move(alg, i, move_modifications(m))
        end
      perms + algs + [alg.inverse]
    end

    # Creates all modifications of an alg that follow a certain pattern, e.g.
    # A B A' B' where A and B are single moves.
    # Takes a block that takes the moves A and B as arguments and returns an
    # algorithm that implements the pattern.
    def alg_modifications_with_pattern(algorithm, &pattern)
      algorithm.moves.uniq(&:axis_face).permutation(2).flat_map do |a, b|
        [a, a.inverse].product([b, b.inverse]).map(&pattern)
      end.uniq
    end

    def comm_sexy_insert_modifications(algorithm)
      raise ArgumentError unless algorithm.length == 4

      alg_modifications_with_pattern(algorithm) do |a, b|
        TwistyPuzzles::Algorithm.new([a, b, a.inverse, b.inverse])
      end
    end

    def comm_insert_modifications(algorithm)
      raise ArgumentError unless algorithm.length == 3

      alg_modifications_with_pattern(algorithm) do |a, b|
        TwistyPuzzles::Algorithm.new([a, b, a.inverse])
      end
    end

    def comm_part_modifications(algorithm)
      case algorithm.moves.length
      when 1 then alg_modifications(algorithm)
      when 3 then comm_insert_modifications(algorithm)
      when 4 then comm_sexy_insert_modifications(algorithm)
      else [algorithm]
      end
    end

    def setup_commutator_modifications(commutator)
      setup_modifications = alg_modifications(commutator.setup)
      inner_commutator_modifications = commutator_modifications(commutator.inner_commutator)
      modification_combinations = setup_modifications.product(inner_commutator_modifications)
      modification_combinations.map do |setup, comm|
        TwistyPuzzles::SetupCommutator.new(setup, comm)
      end.uniq
    end

    def pure_commutator_modifications(commutator)
      left_modifications = comm_part_modifications(commutator.first_part)
      right_modifications = comm_part_modifications(commutator.second_part)
      modification_combinations = left_modifications.product(right_modifications)
      modification_combinations.flat_map do |a, b|
        [TwistyPuzzles::PureCommutator.new(a, b), TwistyPuzzles::PureCommutator.new(b, a)]
      end.uniq
    end

    def slash_commutator_modifications(commutator)
      left_modifications = comm_part_modifications(commutator.first_part)
      right_modifications = comm_part_modifications(commutator.second_part)
      modification_combinations = left_modifications.product(right_modifications)
      modification_combinations.flat_map do |a, b|
        [TwistyPuzzles::SlashCommutator.new(a, b), TwistyPuzzles::SlashCommutator.new(b, a)]
      end.uniq
    end

    def fake_commutator_modifications(commutator)
      alg_modifications(commutator.algorithm).map { |a| TwistyPuzzles::FakeCommutator.new(a) }
    end

    def commutator_sequence_modifications(commutator_sequence)
      if commutator_sequence.commutators.length == 2
        left_modifications = commutator_modifications(commutator_sequence.commutators.first)
        right_modifications = commutator_modifications(commutator_sequence.commutators.last)
        left_modifications.product(right_modifications).map { |a, b| TwistyPuzzles::CommutatorSequence.new([a, b]) }
      else
        commutator_sequence
      end
    end

    def commutator_modifications(commutator)
      case commutator
      when TwistyPuzzles::SetupCommutator
        setup_commutator_modifications(commutator)
      when TwistyPuzzles::SlashCommutator
        slash_commutator_modifications(commutator)
      when TwistyPuzzles::PureCommutator
        pure_commutator_modifications(commutator)
      when TwistyPuzzles::FakeCommutator
        fake_commutator_modifications(commutator)
      when TwistyPuzzles::CommutatorSequence
        commutator_sequence_modifications(commutator)
      else
        raise ArgumentError
      end
    end
  end
end
