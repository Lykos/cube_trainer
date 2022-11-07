# frozen_string_literal: true

require 'twisty_puzzles'
require_relative 'alg_modifications_helper'
require_relative 'case_reverse_engineer'

module CubeTrainer
  # Class that checks whether a commutator algorithm does
  # what it's supposed to do and potentially fixes broken ones.
  class CaseChecker
    include TwistyPuzzles::CubePrintHelper

    # Represents one case where we found a fixed algorithm.
    class Fix
      def initialize(casee, fixed_algorithm)
        @casee = casee
        @fixed_algorithm = fixed_algorithm
      end

      attr_reader :casee, :fixed_algorithm

      def with_case(casee)
        raise unless @casee.equivalent?(casee)

        Fix.new(casee, @fixed_algorithm)
      end
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
      @reverse_engineer = CaseReverseEngineer.new(cube_size: cube_size)
      reset
    end

    attr_reader :unfixable_algs, :error_algs, :outside_algs, :diagonal_algs

    def reset
      @total_algs = 0
      @broken_algs = 0
      @unfixable_algs = 0
      @error_algs = 0
      @outside_algs = 0
      @diagonal_algs = 0
    end

    def fixes
      @fixes ||= []
    end

    def found_problems?
      @broken_algs.positive? || @error_algs.positive?
    end

    # Count an alg with a parse error or something like that that is broken before the checker gets
    # to see it.
    def count_error_alg(cell_description, error_message)
      Rails.logger.debug do
        "Algorithm for #{cell_description} has a problem: " \
          "#{error_message}."
      end
      @total_algs += 1
      @error_algs += 1
    end

    def count_outside_alg(cell_description, algorithm)
      Rails.logger.debug do
        "Algorithm for #{cell_description} #{algorithm} is outside of the " \
          'valid part of the table.'
      end
      @outside_algs += 1
      # We don't count total_algs since this is outside of the valid part.
    end

    def count_diagonal_alg(cell_description, _algorithm)
      Rails.logger.debug do
        "Algorithm for #{cell_description} #{cell.algorithm} is in the " \
          'diagonal of the table.'
      end
      @diagonal_algs += 1
      # We don't count total_algs since this is outside of the valid part.
    end

    def log_failure_report
      Rails.logger.info "#{@error_algs} unparseable algs and #{@broken_algs} " \
                        "incorrect algs of #{@total_algs}."
      Rails.logger.info " #{@unfixable_algs} were unfixable." if @unfixable_algs.positive?
      log_outside_report
    end

    def log_parse_report
      Rails.logger.info "Parsed #{@total_algs} algs."
      log_outside_report
    end

    def log_outside_report
      Rails.logger.debug { "#{@outside_algs} were outside of the valid part of the table" } if @outside_algs.positive?
      if @diagonal_algs.positive? # rubocop:disable Style/GuardClause
        Rails.logger.debug { "#{@diagonal_algs} were in the diagonal of the table" }
      end
    end

    def log_incorrect(cell_description, commutator)
      return unless @verbose

      Rails.logger.debug do
        "Algorithm for #{cell_description} #{commutator} " \
          "doesn't do what it's expected to do."
      end
    end

    def handle_incorrect(cell_description, commutator, alg)
      log_incorrect(cell_description, commutator)
      @broken_algs += 1

      # Try to find a fix, but only if verbose is enabled, otherwise that is pointless.
      if @find_fixes
        if (fix = find_fix(commutator, cell_description.pattern))
          push_fix(cell_description, fix)
          return CheckAlgResult.new(:fix_found, casee: fix.casee, fix: fix.fixed_algorithm)
        else
          handle_unfixable_alg(alg)
        end
      end
      CheckAlgResult::UNFIXABLE
    end

    def push_fix(cell_description, fix)
      fixes.push(fix)
      return unless @verbose

      Rails.logger.debug do
        "For #{cell_description} found fix #{fix.fixed_algorithm}."
      end
    end

    # Result of checking an algorithm.
    # The algorithm can be
    # * correct
    # * incorrect and we have a fix
    # * incorrect and we have no fix
    class CheckAlgResult
      def initialize(result, fix: nil, casee: nil)
        @result = result
        @fix = fix
        @casee = casee
      end

      def correct?
        @result == :correct
      end

      UNFIXABLE = CheckAlgResult.new(:unfixable)

      attr_reader :result, :casee, :fix
    end

    # Returns the case if the alg solves the pattern and nil otherwise
    def alg_case_for_pattern(alg, pattern)
      casee = @reverse_engineer.find_case(alg)
      casee && pattern.match?(casee) ? casee : nil
    end

    def check_alg(cell_description, commutator)
      alg = commutator.algorithm
      @total_algs += 1

      if (casee = alg_case_for_pattern(alg, cell_description.pattern))
        CheckAlgResult.new(:correct, casee: casee)
      else
        handle_incorrect(cell_description, commutator, alg)
      end
    end

    private

    include AlgModificationsHelper

    def find_fix(commutator, pattern)
      commutator_modifications(commutator).each do |fix|
        fix_alg = fix.algorithm
        if (casee = alg_case_for_pattern(fix_alg, pattern))
          return Fix.new(casee, fix)
        end
      end
      nil
    end

    def handle_unfixable_alg(_alg)
      count_unfixable_alg
      return unless @verbose

      Rails.logger.debug "Couldn't find a fix for this alg."
    end

    def count_unfixable_alg
      @unfixable_algs += 1
    end
  end
end
