# frozen_string_literal: true

require 'cube_trainer/commutator_reverse_engineer'
require 'cube_trainer/training/commutator_hinter'
require 'cube_trainer/commonality_finder'
require 'cube_trainer/buffer_helper'
require 'cube_trainer/commutator_checker'
require 'cube_trainer/training/hint_parser'
require 'twisty_puzzles'
require 'twisty_puzzles/utils'

module CubeTrainer
  module Training
    # Stub commutator checker that just says everything is always okay.
    class CommutatorCheckerStub
      def initialize
        @total_algs = 0
      end

      attr_reader :total_algs

      def check_alg(*_args)
        @total_algs += 1
        CommutatorChecker::CheckAlgResult::CORRECT
      end

      def found_problems?
        false
      end

      def count_error_alg; end

      def parse_report; end
    end

    # Represents an empty entry in a commutator table.
    class EmptyEntry
      def self.maybe_letter_pair; end
    end

    # Class that parses a commutator file.
    class CommutatorHintParser < HintParser
      include TwistyPuzzles::Utils::StringHelper
      include TwistyPuzzles
      TEST_COMMS_MODES = %i[ignore warn fail].freeze
      BLACKLIST = ['flip'].freeze

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/ParameterLists
      def initialize(
        part_type:,
        buffer:,
        letter_scheme:,
        color_scheme:,
        write_fixes:,
        verbose:,
        cube_size:,
        test_comms_mode:
      )
        CubeState.check_cube_size(cube_size)
        unless TEST_COMMS_MODES.include?(test_comms_mode)
          raise ArgumentError, "Invalid test comms mode #{test_comms_mode}. " \
                               "Allowed are: #{TEST_COMMS_MODES.inspect}"
        end
        if test_comms_mode == :warn && !verbose
          raise ArgumentError, 'Having test_comms_mode == :warn, but !verbose is pointless.'
        end

        super()
        @part_type = part_type
        @buffer = buffer
        @name = self.class.name_with_buffer_name(part_type, buffer.to_s.downcase)
        @letter_scheme = letter_scheme
        @color_scheme = color_scheme
        @write_fixes = write_fixes
        @verbose = verbose
        @cube_size = cube_size
        @test_comms_mode = test_comms_mode
      end
      # rubocop:enable Metrics/ParameterLists
      # rubocop:enable Metrics/MethodLength

      attr_reader :name, :part_type, :buffer, :verbose, :cube_size, :test_comms_mode

      def self.name_with_buffer_name(part_type, buffer_name)
        "#{buffer_name}_#{snake_case_class_name(part_type)}"
      end

      def self.buffers_with_hints(part_type)
        buffer_extraction_regexp = csv_file(name_with_buffer_name(part_type, '(.*)'))
        Dir.glob(csv_file(name_with_buffer_name(part_type, '*'))).map do |file|
          part_type.parse(file.match(buffer_extraction_regexp)[1])
        end
      end

      def letter_pair(part0, part1)
        LetterPair.new([part0, part1].map { |p| @letter_scheme.letter(p) })
      end

      def warn_comms?
        @test_comms_mode != :ignore && @verbose
      end

      def fail_comms?
        @test_comms_mode == :fail
      end

      # Recognizes special cell values that are blacklisted because they are not commutators
      def blacklisted?(value)
        BLACKLIST.include?(value.downcase)
      end

      # Represents one location in a spreadsheet with all kind of indexing metadata.
      class CellDescription
        def initialize(name, row_index, column_index, letter_pair)
          @name = name
          @row_index = row_index
          @column_index = column_index
          @letter_pair = letter_pair
        end

        attr_reader :name, :row_index, :column_index, :letter_pair

        COLUMN_NAMES = ('A'..'Z').to_a

        def spreadsheet_index
          "#{@name} #{COLUMN_NAMES[@column_index]}#{@row_index + 1}"
        end

        def to_s
          letter_pair_suffix = @letter_pair ? " #{@letter_pair}" : ''
          "#{@name}#{letter_pair_suffix} at #{spreadsheet_index}"
        end
      end

      # Represents an entry with an alg in a commutator table.
      class AlgEntry
        def initialize(letter_pair, algorithm)
          @maybe_letter_pair = letter_pair
          @algorithm = algorithm
        end

        attr_reader :letter_pair, :algorithm
        attr_accessor :maybe_letter_pair
      end

      # Represents an erroneous entry in a commutator table.
      class ErrorEntry
        def initialize(error_message)
          @error_message = error_message
          @maybe_letter_pair = nil
        end

        attr_reader :error_message
        attr_accessor :maybe_letter_pair
      end

      def add_nils_to_table(table)
        max_row_length = table.map(&:length).max
        nil_array = [nil]
        table.map { |row| row + (nil_array * (max_row_length - row.length)) }
      end

      def parse_hints_internal(raw_hints)
        parse_hint_table(raw_hints, add_nils_to_table(raw_hints))
      end

      def checker
        @checker ||=
          if @test_comms_mode == :ignore
            CommutatorCheckerStub.new
          else
            CommutatorChecker.new(
              part_type: @part_type,
              buffer: @buffer,
              color_scheme: @color_scheme,
              letter_scheme: @letter_scheme,
              cube_size: @cube_size,
              verbose: @verbose,
              find_fixes: @verbose
            )
          end
      end

      def reverse_engineer
        @reverse_engineer ||=
          CommutatorReverseEngineer.new(@part_type, @buffer, @letter_scheme, @cube_size)
      end

      def parse_hint_table_cell(cell)
        return EmptyEntry if cell.blank? || blacklisted?(cell)

        alg = parse_commutator(cell, complete_parse: false)
        # Ignore very short algorithms. They are never valid and they can be things like piece
        # types.
        return EmptyEntry if alg.algorithm.length <= 3

        maybe_letter_pair = reverse_engineer.find_letter_pair(alg.algorithm)
        AlgEntry.new(maybe_letter_pair, alg)
      rescue TwistyPuzzles::CommutatorParseError => e
        ErrorEntry.new("Couldn't parse commutator: #{e}")
      end

      def parse_alg_table(hint_table)
        alg_table = hint_table.map { |row| row.map { nil } }
        hint_table.each_with_index do |row, row_index|
          row.each_with_index do |cell, col_index|
            alg_table[row_index][col_index] = parse_hint_table_cell(cell)
          end
        end
        alg_table
      end

      # Process a cell of an alg table that is outside the range where we expect algorithms.
      def process_outside_cell(cell_description, cell)
        # Ignore this if it's not an alg entry. Any invalid stuff can be outside the
        # interesting part of the table.
        return unless cell.is_a?(AlgEntry)
        return unless warn_comms?

        puts "Algorithm for #{cell_description} #{cell.algorithm} is outside of the valid " \
             'part of the table.'
      end

      # Process a cell in the diagonal of an alg table where we don't expect algorithms.
      def process_diagonal_cell(cell_description, cell)
        # Ignore this if it's not an alg entry. Any invalid stuff can be outside the
        # interesting part of the table.
        return unless cell.is_a?(AlgEntry)
        return unless warn_comms?

        puts "Algorithm for #{cell_description} #{cell.algorithm} is in the diagonal of table."
      end

      def process_error_cell(cell_description, cell)
        checker.count_error_alg
        return unless warn_comms?

        puts "Algorithm for #{cell_description} has a problem: " \
             "#{cell.error_message}."
      end

      def process_algorithm_cell(hints, cell_description, cell)
        commutator = cell.algorithm
        check_result = checker.check_alg(cell_description, commutator)
        hints[cell_description.letter_pair] = commutator if check_result.result == :correct
      end

      def process_alg_table_cell(hints, cell_description, cell)
        if cell_description.letter_pair.nil?
          process_outside_cell(cell_description, cell)
        elsif cell_description.letter_pair.pair_of_equal_letters?
          process_diagonal_cell(cell_description, cell)
        elsif cell.is_a?(ErrorEntry)
          process_error_cell(cell_description, cell)
        elsif cell.is_a?(AlgEntry)
          process_algorithm_cell(hints, cell_description, cell)
        end
      end

      def process_alg_table(alg_table, interpretation)
        hints = {}
        alg_table.each_with_index do |row, row_index|
          row.each_with_index do |cell, col_index|
            letter_pair = interpretation.letter_pair(row_index, col_index)
            cell_description = CellDescription.new(name, row_index, col_index, letter_pair)
            process_alg_table_cell(hints, cell_description, cell)
          end
        end
        hints
      end

      def parse_hint_table(raw_hints, hint_table)
        # First parse whatever we can out of the hint table
        alg_table = parse_alg_table(hint_table)

        # Now figure out whether rows are the first piece or the second piece.
        interpretation = CommonalityFinder.interpret_table(alg_table)

        # Now check everything and construct the hint table.
        hints = process_alg_table(alg_table, interpretation)
        maybe_write_fixes(raw_hints)
        output_final_report

        hints
      end

      def maybe_write_fixes(raw_hints)
        return unless @write_fixes && !checker.fixes.empty?

        checker.fixes.each do |fix|
          desc = fix.cell_description
          raw_hints[desc.row_index][desc.column_index] = fix.fixed_algorithm.to_s
        end
        write_hints(raw_hints)
      end

      def output_final_report
        if checker.found_problems?
          puts checker.failure_report if warn_comms?
          raise checker.failure_report if fail_comms?
        elsif @verbose
          puts checker.parse_report
        end
      end

      def hinter_class
        CommutatorHinter
      end

      def self.maybe_parse_hints(part_type, options)
        buffer = BufferHelper.determine_buffer(part_type, options)
        hint_parser = new(
          part_type: part_type,
          buffer: buffer,
          letter_scheme: options.letter_scheme,
          color_scheme: options.color_scheme,
          verbose: options.verbose,
          write_fixes: options.write_fixes,
          cube_size: options.cube_size,
          test_comms_mode: options.test_comms_mode
        )
        hint_parser.maybe_parse_hints
      end
    end
  end
end
