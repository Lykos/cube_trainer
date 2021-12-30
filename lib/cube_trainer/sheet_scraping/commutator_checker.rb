# frozen_string_literal: true

require 'twisty_puzzles'
require_relative 'alg_modifications_helper'
require_relative 'commutator_reverse_engineer'

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

    def initialize(
      cube_size:,
      verbose: false,
      find_fixes: false
    )
      TwistyPuzzles::CubeState.check_cube_size(cube_size)

      @cube_size = cube_size
      @verbose = verbose
      @find_fixes = find_fixes
      @reverse_engineer = CommutatorReverseEngineer.new(cube_size: cube_size)
      reset
    end

    attr_reader :unfixable_algs, :error_algs

    def reset
      @total_algs = 0
      @broken_algs = 0
      @unfixable_algs = 0
      @error_algs = 0
    end

    def fixes
      @fixes ||= []
    end

    def found_problems?
      @broken_algs.positive? || @error_algs.positive?
    end

    # Count an alg with a parse error or something like that that is broken before the checker gets
    # to see it.
    def count_error_alg
      @total_algs += 1
      @error_algs += 1
    end

    def failure_report
      msg = "#{@error_algs} unparseable algs and #{@broken_algs} " \
            "incorrect algs of #{@total_algs}."
      msg << " #{@unfixable_algs} were unfixable." if @unfixable_algs.positive?
      msg
    end

    def parse_report
      "Parsed #{@total_algs} algs."
    end

    def handle_incorrect(cell_description, commutator, alg, part_cycle)
      if @verbose
        Rails.logger.warn "Algorithm for #{cell_description} #{commutator} " \
                          "doesn't do what it's expected to do."
      end
      @broken_algs += 1

      # Try to find a fix, but only if verbose is enabled, otherwise that is pointless.
      if @find_fixes
        if (fix = find_fix(commutator, part_cycle))
          fixes.push(Fix.new(cell_description, fix))
          Rails.logger.info "Found fix #{fix}." if @verbose
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

    def alg_solves_case(alg, part_cycle)
      part_cycles = @reverse_engineer.find_part_cycles(alg)
      part_cycles.length == 1 && part_cycles.first.equivalent?(part_cycle)
    end

    def check_alg(cell_description, commutator)
      part_cycle = cell_description.part_cycle
      alg = commutator.algorithm
      @total_algs += 1
      if alg_solves_case(alg, cell_description.part_cycle)
        CheckAlgResult::CORRECT
      else
        handle_incorrect(cell_description, commutator, alg, part_cycle)
      end
    end

    private

    include AlgModificationsHelper

    def find_fix(commutator, part_cycle)
      commutator_modifications(commutator).each do |fix|
        fix_alg = fix.algorithm
        return fix if alg_solves_case(fix_alg, part_cycle)
      end
      nil
    end

    def handle_unfixable_alg(alg)
      count_unfixable_alg
      return unless @verbose

      Rails.logger.warn "Couldn't find a fix for this alg."
    end

    def count_unfixable_alg
      @unfixable_algs += 1
    end
  end
end
