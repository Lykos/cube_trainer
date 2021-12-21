require_relative 'commutator_reverse_engineer'
require_relative 'commutator_checker'
require_relative 'commonality_finder'
require 'twisty_puzzles'

module CubeTrainer
  module SheetScraping
    # Class that extracts algorithms from a table.
    class AlgExtractor
      class AlgSet
        def initialize(part_type:, buffer:, algs:, fixes:)
          @part_type = part_type
          @buffer = buffer
          @algs = algs
          @fixes = fixes
        end

        attr_reader :part_type, :buffer, :algs, :fixes
      end

      def self.extract_alg_set(table)
        new.extract_alg_set(table)
      end

      def extract_alg_set(table)
        # First parse whatever we can out of the hint table
        alg_table = parse_alg_table(add_nils_to_table(table.values))

        # Now figure out whether rows are the first piece or the second piece.
        interpretation = CommonalityFinder.interpret_table(alg_table, @buffer)
        return unless interpretation.buffer

        Rails.logger.info "Sheet #{table.sheet_info.title} is for #{interpretation.part_type.name.split('::').last.downcase}s with buffer #{interpretation.buffer}"
        # Now check everything and construct the alg table.
        cube_size = interpretation.part_type.exists_on_cube_size?(3) ? 3 : 5
        @checker =
          CommutatorChecker.new(
            part_type: interpretation.part_type,
            cube_size: cube_size,
            verbose: true,
            show_cube_states: false,
            find_fixes: true,
          )
        algs = process_alg_table(table.sheet_info, alg_table, interpretation)
        log_final_report

        AlgSet.new(
          part_type: interpretation.part_type,
          buffer: interpretation.buffer,
          algs: algs,
          fixes: @checker.fixes
        )
      end

      private

      include TwistyPuzzles

      # Represents one location in a spreadsheet with all kind of indexing metadata.
      class CellDescription
        def initialize(name, row_index, column_index, part_cycle)
          raise TypeError unless part_cycle.nil? || part_cycle.is_a?(TwistyPuzzles::PartCycle)

          @name = name
          @row_index = row_index
          @column_index = column_index
          @part_cycle = part_cycle
        end

        attr_reader :name, :row_index, :column_index, :part_cycle

        COLUMN_NAMES = ('A'..'Z').to_a

        def spreadsheet_index
          "#{@name} #{COLUMN_NAMES[@column_index]}#{@row_index + 1}"
        end

        def to_s
          part_cycle_suffix = @part_cycle ? " #{@part_cycle}" : ''
          "#{@name}#{part_cycle_suffix} at #{spreadsheet_index}"
        end
      end

      # Represents an empty entry in a commutator table.
      class EmptyEntry
        def self.maybe_part_cycle; end
      end

      # Represents an entry with an alg in a commutator table.
      class AlgEntry
        def initialize(part_cycle, algorithm)
          @maybe_part_cycle = part_cycle
          @algorithm = algorithm
        end

        attr_reader :algorithm
        attr_accessor :maybe_part_cycle
      end

      # Represents an erroneous entry in a commutator table.
      class ErrorEntry
        def initialize(error_message)
          @error_message = error_message
          @maybe_part_cycle = nil
        end

        attr_reader :error_message
        attr_accessor :maybe_part_cycle
      end
      # Process a cell of an alg table that is outside the range where we expect algorithms.
      def process_outside_cell(cell_description, cell)
        # Ignore this if it's not an alg entry. Any invalid stuff can be outside the
        # interesting part of the table.
        return unless cell.is_a?(AlgEntry)

        Rails.logger.warn "Algorithm for #{cell_description} #{cell.algorithm} is outside of the valid " \
                          'part of the table.'
      end

      # Process a cell in the diagonal of an alg table where we don't expect algorithms.
      def process_diagonal_cell(cell_description, cell)
        # Ignore this if it's not an alg entry. Any invalid stuff can be outside the
        # interesting part of the table.
        return unless cell.is_a?(AlgEntry)

        Rails.logger.warn "Algorithm for #{cell_description} #{cell.algorithm} is in the diagonal of table."
      end

      def process_error_cell(cell_description, cell)
        @checker.count_error_alg

        Rails.logger.warn "Algorithm for #{cell_description} has a problem: " \
                          "#{cell.error_message}."
      end

      def process_algorithm_cell(hints, cell_description, cell)
        commutator = cell.algorithm
        check_result = @checker.check_alg(cell_description, commutator)
        hints[cell_description.part_cycle] = commutator if check_result.result == :correct
      end

      def process_alg_table_cell(hints, cell_description, cell)
        if cell_description.part_cycle.nil?
          process_outside_cell(cell_description, cell)
        elsif cell_description.part_cycle.length == 3 &&
              cell_description.part_cycle.parts[1].turned_equals?(cell_description.part_cycle.parts[2])
          process_diagonal_cell(cell_description, cell)
        elsif cell.is_a?(ErrorEntry)
          process_error_cell(cell_description, cell)
        elsif cell.is_a?(AlgEntry)
          process_algorithm_cell(hints, cell_description, cell)
        end
      end

      def process_alg_table(sheet_info, alg_table, interpretation)
        hints = {}
        alg_table.each_with_index do |row, row_index|
          row.each_with_index do |cell, col_index|
            part_cycle = interpretation.part_cycle(row_index, col_index)
            cell_description = CellDescription.new(sheet_info.range, row_index, col_index, part_cycle)
            process_alg_table_cell(hints, cell_description, cell)
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
          CommutatorReverseEngineer.new(cube_size: 3)
      end

      def big_cube_reverse_engineer
        @big_cube_reverse_engineer ||=
          CommutatorReverseEngineer.new(cube_size: 5)
      end      

      def log_final_report
        if @checker.found_problems?
          Rails.logger.warn @checker.failure_report
        else
          Rails.logger.info @checker.parse_report
        end
      end
      
      BLACKLIST = ['flip'].freeze

      # Recognizes special cell values that are blacklisted because they are not commutators
      def blacklisted?(value)
        BLACKLIST.include?(value.downcase)
      end

      def maybe_part_cycle(algorithm)
        part_cycles = reverse_engineer.find_part_cycles(algorithm)
        return part_cycles.first if part_cycles.length == 1

        part_cycles = big_cube_reverse_engineer.find_part_cycles(algorithm)
        return part_cycles.first if part_cycles.length == 1

        # If we have one wing cycle, we ignore that it's not center safe and some equivalent centers get swapped.
        wing_cycles = part_cycles.select { |c| c.part_type == TwistyPuzzles::Wing }
        if wing_cycles.length == 1
          other_cycles = part_cycles - wing_cycles
          return wing_cycles[0] if other_cycles.all? { |c| equivalent_center_cycle?(c) }
        end
        nil
      end

      def equivalent_center_cycle?(part_cycle)
        part_cycle.part_type.is_a?(TwistyPuzzles::MoveableCenter) && part_cycle.parts.all? { |p| p.face_symbol == part_cycle.first.face_symbol }
      end

      def parse_table_cell(cell)
        return EmptyEntry if cell.blank? || blacklisted?(cell)

        # No complete parse because there might be some sort of (AB) at the end of the cell.
        alg = parse_commutator(cell, complete_parse: false)

        # Ignore very short algorithms. They are never valid and they can be things like piece
        # types.
        return EmptyEntry if alg.algorithm.length <= 3

        AlgEntry.new(maybe_part_cycle(alg.algorithm), alg)
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
