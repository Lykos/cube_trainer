# frozen_string_literal: true

require 'twisty_puzzles'

module CubeTrainer
  # Class that checks whether a commutator algorithm does
  # what it's supposed to do and potentially fixes broken ones.
  class CommutatorChecker
    include TwistyPuzzles::CubePrintHelper

    # Represents one case where we found a fixed algorithm.
    class Fix
      def initialize(cell_description, fixed_algorithm)
        @cell_description = cell_description
        @fixed_algorithm = fixed_algorithm
      end

      attr_reader :cell_description, :fixed_algorithm
    end

    # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
    def initialize(
      part_type:,
      buffer:,
      color_scheme:,
      letter_scheme:,
      cube_size:,
      verbose: false,
      show_cube_states: false,
      find_fixes: false,
      incarnation_index: 0
    )
      TwistyPuzzles::CubeState.check_cube_size(cube_size)
      unless part_type.is_a?(Class) && part_type.ancestors.include?(TwistyPuzzles::Part)
        raise TypeError
      end
      raise TypeError unless buffer.instance_of?(part_type)
      raise TwistyPuzzles::ColorScheme unless color_scheme.is_a?(TwistyPuzzles::ColorScheme)

      @part_type = part_type
      @buffer = buffer
      @color_scheme = color_scheme
      @letter_scheme = letter_scheme
      @cube_size = cube_size
      @verbose = verbose
      @show_cube_states = show_cube_states
      @find_fixes = find_fixes
      @incarnation_index = incarnation_index
      init_helpers
      reset
    end
    # rubocop:enable Metrics/ParameterLists, Metrics/MethodLength

    def init_helpers
      @alg_cube_state = @color_scheme.solved_cube_state(@cube_size)
      @cycle_cube_state = @color_scheme.solved_cube_state(@cube_size)
      @part_cycle_factory = TwistyPuzzles::PartCycleFactory.new(@cube_size, @incarnation_index)
    end

    def reset
      @total_algs = 0
      @broken_algs = 0
      # Unknown by default. Only relevant if we actually search for fixes.
      @unfixable_algs = nil
      @error_algs = 0
    end

    def fixes
      @fixes ||= []
    end

    def found_problems?
      @broken_algs.positive? || @error_algs.positive?
    end

    def construct_cycle(parts)
      @part_cycle_factory.construct([@buffer] + parts)
    end

    # Count an alg with a parse error or something like that that is broken before the checker gets
    # to see it.
    def count_error_alg
      @total_algs += 1
      @error_algs += 1
    end

    def failure_report
      msg = "#{@error_algs} error algs and #{@broken_algs} " \
            "broken algs of #{@total_algs}."
      msg << " #{@unfixable_algs} were unfixable." if @unfixable_algs
      msg
    end

    def parse_report
      "Parsed #{@total_algs} algs."
    end

    def handle_incorrect(cell_description, commutator, alg, desired_state)
      if @verbose
        puts "Algorithm for #{cell_description} #{commutator} " \
             "doesn't do what it's expected to do."
      end
      @broken_algs += 1

      # Try to find a fix, but only if verbose is enabled, otherwise that is pointless.
      if @find_fixes
        if (fix = find_fix(commutator, desired_state))
          fixes.push(Fix.new(cell_description, fix))
          puts "Found fix #{fix}." if @verbose
          return CheckAlgResult.new(:fix_found, fix)
        else
          handle_unfixable_alg(alg)
        end
      end
      CheckAlgResult::UNFIXABLE
    end

    # Result of checking an algorithm.
    # The algorithm can be
    # * correct
    # * incorrect and we have a fix
    # * incorrect and we have no fix
    class CheckAlgResult
      def initialize(result, fix = nil)
        @result = result
        @fix = fix
      end

      CORRECT = CheckAlgResult.new(:correct)
      UNFIXABLE = CheckAlgResult.new(:unfixable)

      attr_reader :result, :fix
    end

    def alg_reaches_state(alg, desired_state)
      alg.apply_temporarily_to(@alg_cube_state) { |s| s == desired_state }
    end

    def check_alg(cell_description, commutator)
      parts =
        cell_description.letter_pair.letters.map do |l|
          @letter_scheme.for_letter(@part_type, l)
        end
      # Apply alg and cycle
      cycle = construct_cycle(parts)
      cycle.apply_temporarily_to(@cycle_cube_state) do |cycle_state|
        alg = commutator.algorithm
        @total_algs += 1

        # compare
        if alg_reaches_state(alg, cycle_state)
          CheckAlgResult::CORRECT
        else
          handle_incorrect(cell_description, commutator, alg, cycle_state)
        end
      end
    end

    private

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

    def alg_modifications(alg)
      perms = permutation_modifications(alg)
      a, *as = alg.moves.map { |m| move_modifications(m) }
      perms + a.product(*as).map { |ms| TwistyPuzzles::Algorithm.new(ms) }
    end

    def comm_sexy_insert_modifications(algorithm)
      raise ArgumentError unless algorithm.length == 4

      a = algorithm.moves[0]
      b = algorithm.moves[1]
      [
        TwistyPuzzles::Algorithm.new([a, b, a.inverse, b.inverse]),
        TwistyPuzzles::Algorithm.new([a.inverse, b.inverse, a, b]),
        TwistyPuzzles::Algorithm.new([a, b.inverse, a.inverse, b]),
        TwistyPuzzles::Algorithm.new([a.inverse, b, b, a.inverse]),
        TwistyPuzzles::Algorithm.new([b, a, b.inverse, a.inverse]),
        TwistyPuzzles::Algorithm.new([b.inverse, a.inverse, b, a]),
        TwistyPuzzles::Algorithm.new([b, a.inverse, b.inverse, a]),
        TwistyPuzzles::Algorithm.new([b.inverse, a, b, a.inverse]),
      ].uniq
    end

    def comm_insert_modifications(algorithm)
      raise ArgumentError unless algorithm.length == 3

      a = algorithm.moves[0]
      b = algorithm.moves[2]
      move_modifications(algorithm.moves[1]).flat_map do |m|
        [
          TwistyPuzzles::Algorithm.new([a, m, a.inverse]),
          TwistyPuzzles::Algorithm.new([a.inverse, m, a]),
          TwistyPuzzles::Algorithm.new([b, m, b.inverse]),
          TwistyPuzzles::Algorithm.new([b.inverse, m, b])
        ].uniq
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
      else
        raise ArgumentError
      end
    end

    def find_fix(commutator, desired_state)
      commutator_modifications(commutator).each do |fix|
        fix_alg = fix.algorithm
        return fix if alg_reaches_state(fix_alg, desired_state)
      end
      nil
    end

    def handle_unfixable_alg(alg)
      count_unfixable_alg
      return unless @verbose

      puts "Couldn't find a fix for this alg."
      return unless @show_cube_states
      puts 'actual'
      puts alg.apply_temporarily_to(@alg_cube_state) { |s| cube_string(s, :color) }
      puts 'expected'
      puts cube_string(@cycle_cube_state, :color)
    end

    def count_unfixable_alg
      @unfixable_algs ||= 0
      @unfixable_algs += 1
    end
  end
end
