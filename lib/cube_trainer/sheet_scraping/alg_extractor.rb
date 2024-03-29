# frozen_string_literal: true

require_relative 'case_reverse_engineer'
require_relative 'case_checker'
require_relative 'commonality_finder'
require 'twisty_puzzles'

module CubeTrainer
  module SheetScraping
    # Class that extracts algorithms from a table.
    class AlgExtractor
      # One alg set that is typically learned and practiced as a unit,
      # e.g. the edge commutators for buffer UF.
      # Eventually gets mapped into an AlgSet model and
      # its Alg submodels after some postprocessing.
      class AlgSet
        def initialize(case_set:, algs:, checker:)
          @case_set = case_set
          @algs = algs
          @fixes =
            checker.fixes.map do |fix|
              casee = case_set.create_strict_matching(fix.casee)
              raise unless case_set.strict_match?(casee)

              fix.with_case(casee)
            end
          @num_unfixable = checker.unfixable_algs
          @num_unparseable = checker.error_algs
          @num_outside = checker.outside_algs
          @num_diagonal = checker.diagonal_algs
        end

        attr_reader :case_set, :algs, :fixes, :num_unfixable, :num_unparseable, :num_outside,
                    :num_diagonal
      end

      def self.extract_alg_set(table)
        new.extract_alg_set(table)
      end

      def extract_alg_set(table)
        # First parse whatever we can out of the hint table
        alg_table = parse_alg_table(add_nils_to_table(table.values))

        # Now figure out whether rows are the first piece or the second piece.
        interpretation = CommonalityFinder.interpret_table(alg_table)
        return unless interpretation.case_set

        # Now check everything and construct the alg table.
        Rails.logger.info "Sheet #{table.sheet_info.title} is for alg set " \
                          "#{interpretation.case_set} for cube size #{interpretation.cube_size}"
        extract_alg_set_for_interpretation(table.sheet_info, alg_table, interpretation)
      end

      private

      include TwistyPuzzles

      # Represents one location in a spreadsheet with all kind of indexing metadata.
      class CellDescription
        def initialize(name, row_index, column_index, pattern)
          raise TypeError unless pattern.nil? || pattern.is_a?(CasePattern::CasePattern)

          @name = name
          @row_index = row_index
          @column_index = column_index
          @pattern = pattern
        end

        attr_reader :name, :row_index, :column_index, :pattern

        COLUMN_NAMES = ('A'..'Z').to_a

        def spreadsheet_index
          "#{@name} #{COLUMN_NAMES[@column_index]}#{@row_index + 1}"
        end

        def to_s
          pattern_suffix = @pattern ? " #{@pattern}" : ''
          "#{@name}#{pattern_suffix} at #{spreadsheet_index}"
        end
      end

      # Represents an empty entry in a commutator table.
      class EmptyEntry
        def self.maybe_case(_cube_size); end
      end

      # Represents an entry with an alg in a commutator table.
      class AlgEntry
        def initialize(cases, algorithm)
          @maybe_cases = cases
          @algorithm = algorithm
        end

        attr_reader :algorithm, :maybe_cases

        def maybe_case(cube_size)
          @maybe_cases[cube_size]
        end
      end

      # Represents an erroneous entry in a commutator table.
      class ErrorEntry
        def initialize(error_message)
          @error_message = error_message
        end

        attr_reader :error_message

        def maybe_case(_cube_size); end
      end

      def create_checker(interpretation)
        CaseChecker.new(
          cube_size: interpretation.cube_size,
          verbose: true,
          find_fixes: true
        )
      end

      def extract_alg_set_for_interpretation(sheet_info, alg_table, interpretation)
        @checker = create_checker(interpretation)
        algs = process_alg_table(sheet_info, alg_table, interpretation)
        log_final_report

        AlgSet.new(
          case_set: interpretation.case_set,
          algs: algs,
          checker: @checker
        )
      end

      # Process a cell of an alg table that is outside the range where we expect algorithms.
      def process_outside_cell(cell_description, cell)
        # Ignore this if it's not an alg entry. Any invalid stuff can be outside the
        # interesting part of the table.
        return unless cell.is_a?(AlgEntry)

        @checker.count_outside_alg(cell_description, cell.algorithm)
      end

      # Process a cell in the diagonal of an alg table where we don't expect algorithms.
      def process_diagonal_cell(cell_description, cell)
        # Ignore this if it's not an alg entry. Any invalid stuff can be outside the
        # interesting part of the table.
        return unless cell.is_a?(AlgEntry)

        @checker.count_diagonal_alg(cell_description, cell.algorithm)
      end

      def process_error_cell(cell_description, cell)
        @checker.count_error_alg(cell_description, cell.error_message)
      end

      def process_algorithm_cell(hints, cell_description, cell, case_set)
        commutator = cell.algorithm
        check_result = @checker.check_alg(cell_description, commutator)
        return unless check_result.correct?

        casee = case_set.create_strict_matching(check_result.casee)
        raise unless case_set.strict_match?(casee)

        hints[casee] = commutator
      end

      def process_alg_table_cell(hints, cell_description, cell, case_set)
        if cell_description.pattern.nil?
          process_outside_cell(cell_description, cell)
        elsif cell.is_a?(ErrorEntry)
          process_error_cell(cell_description, cell)
        elsif cell.is_a?(AlgEntry)
          process_algorithm_cell(hints, cell_description, cell, case_set)
        end
      end

      def process_alg_table(sheet_info, alg_table, interpretation)
        hints = {}
        alg_table.each_with_index do |row, row_index|
          row.each_with_index do |cell, col_index|
            pattern = interpretation.maybe_pattern(row_index, col_index)
            cell_description = CellDescription.new(
              sheet_info.title, row_index, col_index,
              pattern
            )
            process_alg_table_cell(hints, cell_description, cell, interpretation.case_set)
          end
        end
        hints
      end

      def add_nils_to_table(table)
        max_row_length = table.map(&:length).max
        nil_array = [nil]
        table.map { |row| row + (nil_array * (max_row_length - row.length)) }
      end

      def reverse_engineer
        @reverse_engineer ||=
          CaseReverseEngineer.new(cube_size: 3)
      end

      def big_cube_reverse_engineer
        @big_cube_reverse_engineer ||=
          CaseReverseEngineer.new(cube_size: 5)
      end

      def log_final_report
        if @checker.found_problems?
          @checker.log_failure_report
        else
          @checker.log_parse_report
        end
      end

      def maybe_cases(algorithm)
        cases = {}
        cases[3] = reverse_engineer.find_case(algorithm)
        cases[5] = big_cube_reverse_engineer.find_case(algorithm)
        cases
      end

      def parse_table_cell(cell)
        return EmptyEntry if cell.blank?

        # No complete parse because there might be some sort of (AB) at the end of the cell.
        alg = parse_commutator(cell, complete_parse: false)

        # Ignore very short algorithms. They are never valid and they can be things like piece
        # types.
        return EmptyEntry if alg.algorithm.length <= 3

        AlgEntry.new(maybe_cases(alg.algorithm), alg)
      rescue TwistyPuzzles::CommutatorParseError => e
        ErrorEntry.new("Couldn't parse commutator: #{e}")
      end

      def parse_alg_table(table)
        alg_table = table.map { |row| row.map { nil } }
        table.each_with_index do |row, row_index|
          row.each_with_index do |cell, col_index|
            alg_table[row_index][col_index] = parse_table_cell(cell)
          end
        end
        alg_table
      end
    end
  end
end
