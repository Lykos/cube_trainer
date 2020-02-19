# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/cube_state'
require 'cube_trainer/core/commutator'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/cube_print_helper'
require 'cube_trainer/core/part_cycle_factory'

module CubeTrainer
  # Class that checks whether a commutator algorithm does
  # what it's supposed to do and potentially fixes broken ones.
  class CommutatorChecker
    include Core::CubePrintHelper

    def initialize(part_type:,
                   buffer:,
                   piece_name:,
                   color_scheme:,
                   letter_scheme:,
                   cube_size:,
                   verbose: false,
                   find_fixes: false,
                   incarnation_index: 0)
      raise TypeError unless part_type.is_a?(Class) && part_type.ancestors.include?(Core::Part)
      raise TypeError unless buffer.class == part_type
      unless cube_size.is_a?(Integer) && cube_size > 0
        raise ArgumentError, "Unsuitable cube size #{cube_size}."
      end
      raise ColorScheme unless color_scheme.is_a?(ColorScheme)

      @part_type = part_type
      @buffer = buffer
      @piece_name = piece_name
      @color_scheme = color_scheme
      @letter_scheme = letter_scheme
      @cube_size = cube_size
      @verbose = verbose
      @find_fixes = find_fixes
      @incarnation_index = incarnation_index
      @alg_cube_state = @color_scheme.solved_cube_state(cube_size)
      @cycle_cube_state = @color_scheme.solved_cube_state(cube_size)
      @total_algs = 0
      @broken_algs = 0
      # Unknown by default. Only relevant if we actually search for fixes.
      @unfixable_algs = nil
      @error_algs = 0
      @part_cycle_factory = Core::PartCycleFactory.new(cube_size, incarnation_index)
    end

    attr_reader :total_algs, :broken_algs, :unfixable_algs, :error_algs

    def construct_cycle(parts)
      @part_cycle_factory.construct([@buffer] + parts)
    end

    def move_modifications(move)
      [move, move.inverse].uniq
    end

    def permutation_modifications(alg)
      if alg.length <= 3
        alg.moves.permutation.collect { |p| Core::Algorithm.new(p) }
      else
        [alg]
      end
    end

    def alg_modifications(alg)
      perms = permutation_modifications(alg)
      a, *as = alg.moves.map { |m| move_modifications(m) }
      perms + a.product(*as).map { |ms| Core::Algorithm.new(ms) }
    end

    def comm_part_modifications(algorithm)
      if algorithm.moves.length == 1
        alg_modifications(algorithm)
      elsif algorithm.moves.length == 3
        a = algorithm.moves[0]
        b = algorithm.moves[1]
        move_modifications(algorithm.moves[1]).flat_map do |m|
          if a != b.inverse
            lol = [Core::Algorithm.new([a, m, a.inverse]), Core::Algorithm.new([a.inverse, m, a])]
            if a != b
              lol += [Core::Algorithm.new([b, m, b.inverse]), Core::Algorithm.new([b.inverse, m, b])]
            end
            lol
          else
            [Core::Algorithm.new([a, m, b]), Core::Algorithm.new([b, m, a])]
          end
        end
      else
        [algorithm]
      end
    end

    def potential_fixes(commutator)
      if commutator.is_a?(Core::SetupCommutator)
        alg_modifications(commutator.setup).product(potential_fixes(commutator.inner_commutator)).map { |setup, comm| Core::SetupCommutator.new(setup, comm) }
      elsif commutator.is_a?(Core::PureCommutator)
        comm_part_modifications(commutator.first_part).product(comm_part_modifications(commutator.second_part)).flat_map { |a, b| [Core::PureCommutator.new(a, b), Core::PureCommutator.new(b, a)].uniq }
      elsif commutator.is_a?(Core::FakeCommutator)
        alg_modifications(commutator.algorithm).map { |a| Core::FakeCommutator.new(a) }
      else
        raise ArgumentError
      end
    end

    def find_fix(commutator)
      potential_fixes(commutator).each do |fix|
        fix_alg = fix.algorithm
        if fix_alg.apply_temporarily_to(@alg_cube_state) { @cycle_cube_state == @alg_cube_state }
          return fix
        end
      end
      nil
    end

    # Count an alg with a parse error or something like that that is broken before the checker gets to see it.
    def count_error_alg
      @total_algs += 1
      @error_algs += 1
    end

    def count_unfixable_alg
      @unfixable_algs ||= 0
      @unfixable_algs += 1
    end

    private :count_unfixable_alg

    def handle_incorrect(row_description, letter_pair, commutator, alg)
      if @verbose
        puts "Algorithm for #{@piece_name} #{letter_pair} at #{row_description} #{commutator} doesn't do what it's expected to do."
      end
      @broken_algs += 1

      # Try to find a fix, but only if verbose is enabled, otherwise that is pointless.
      if @find_fixes
        if (fix = find_fix(commutator))
          puts "Found fix #{fix}." if @verbose
          return CheckAlgResult.new(:fix_found, fix)
        else
          count_unfixable_alg
          if @verbose
            puts "Couldn't find a fix for this alg."
            puts 'actual'
            puts alg.apply_temporarily_to(@alg_cube_state) { cube_string(@alg_cube_state, :color) }
            puts 'expected'
            puts cube_string(@cycle_cube_state, :color)
          end
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

      attr_reader :result, :fix

      CORRECT = CheckAlgResult.new(:correct)
      UNFIXABLE = CheckAlgResult.new(:unfixable)
    end

    def check_alg(row_description, letter_pair, commutator)
      parts = letter_pair.letters.map { |l| @letter_scheme.for_letter(@part_type, l) }
      # Apply alg and cycle
      cycle = construct_cycle(parts)
      cycle.apply_temporarily_to(@cycle_cube_state) do
        alg = commutator.algorithm
        @total_algs += 1

        # compare
        correct = alg.apply_temporarily_to(@alg_cube_state) { @cycle_cube_state == @alg_cube_state }

        if correct
          CheckAlgResult::CORRECT
        else
          handle_incorrect(row_description, letter_pair, commutator, alg)
        end
      end
    end
  end
end
