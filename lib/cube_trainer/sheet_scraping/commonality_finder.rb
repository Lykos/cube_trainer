# frozen_string_literal: true

require 'twisty_puzzles'
require 'cube_trainer/training/case_set'

module CubeTrainer
  # Helper class that figures out what rows and columns of a commutator table have in common and
  # what the interpretation of the table is.
  class CommonalityFinder
    # Represents the chosen way to interpret a table of commutators.
    class TableInterpretation
      def initialize(case_set, cube_size, row_interpretations, column_interpretations)
        @case_set = case_set
        @cube_size = cube_size
        @row_interpretations = row_interpretations
        @column_interpretations = column_interpretations
      end

      attr_reader :case_set, :cube_size

      def maybe_pattern(row_index, col_index)
        return unless @case_set

        row_interpretation = @row_interpretations[row_index]
        column_interpretation = @column_interpretations[col_index]
        return unless row_interpretation && column_interpretation

        row_interpretation & column_interpretation
      end
    end

    EMPTY_INTERPRETATION = TableInterpretation.new(nil, 0, [].freeze, [].freeze)

    # Table should be a 2D array where the entries have a method called maybes_case
    # with the cube size as an argument that the case for that cell or nil.
    def self.interpret_table(table)
      transposed_table = table.transpose
      table_interpretations =
        [3, 5].map do |cube_size|
          interpret_table_for_cube_size(table, transposed_table, cube_size)
        end
      # Note that in case of equality, the 3x3 interpretation wins due to our ordering.
      # This is intentional as we want corners to be a 3x3 set even if it works for big
      # cubes, too.
      best_interpretation(table_interpretations, table)
    end

    def self.interpret_table_for_cube_size(table, transposed_table, cube_size)
      case_set = find_case_set(table, cube_size)
      return EMPTY_INTERPRETATION unless case_set

      interpret_table_with_case_set(table, transposed_table, case_set, cube_size)
    end

    def self.interpret_table_with_case_set(table, transposed_table, case_set, cube_size)
      table_interpretations = table_interpretations(table, transposed_table, case_set, cube_size)
      best_interpretation(table_interpretations, table)
    end

    def self.table_interpretations(table, transposed_table, case_set, cube_size)
      [true, false].map do |flip_axes|
        table_interpretation(table, transposed_table, case_set, flip_axes, cube_size)
      end
    end

    def self.table_interpretation(table, transposed_table, case_set, flip_axes, cube_size)
      row_interpretations = find_row_interpretations(table, case_set, flip_axes ? 0 : 1, cube_size)
      column_interpretations =
        find_row_interpretations(transposed_table, case_set, flip_axes ? 1 : 0, cube_size)
      if flip_axes
        row_interpretations, column_interpretations = column_interpretations, row_interpretations
      end
      TableInterpretation.new(
        case_set, cube_size,
        row_interpretations, column_interpretations
      )
    end

    def self.find_case_set(table, cube_size)
      case_set_frequencies = new_counter_hash
      table.map do |row|
        row.map do |cell|
          count_cell_case_sets(cell, case_set_frequencies, cube_size)
        end
      end
      case_set_frequencies.max_by { |_p, v| v }&.first
    end

    def self.count_cell_case_sets(cell, case_set_frequencies, cube_size)
      casee = cell.maybe_case(cube_size)
      return unless casee

      relevant_case_sets(casee).each { |p| case_set_frequencies[p] += 1 }
    end

    def self.relevant_case_sets(casee)
      relevant_top_level_case_sets(casee).flat_map do |case_set|
        case_set.refinements_matching(casee)
      end
    end

    def self.relevant_top_level_case_sets(casee)
      # rubocop:disable Style/SelectByRegexp
      Training::CASE_SETS.select { |p| p.match?(casee) }
      # rubocop:enable Style/SelectByRegexp
    end

    def self.best_interpretation(table_interpretations, table)
      table_interpretations.max_by { |i| interpretation_score(i, table) }
    end

    def self.interpretation_score(table_interpretation, table)
      table.map.with_index do |row, row_index|
        row.map.with_index do |cell, col_index|
          interpretation_pattern = table_interpretation.maybe_pattern(row_index, col_index)
          cell_case = cell.maybe_case(table_interpretation.cube_size)
          present_and_match?(interpretation_pattern, cell_case) ? 1 : 0
        end.sum
      end.sum
    end

    def self.present_and_match?(interpretation_pattern, cell_case)
      interpretation_pattern &&
        cell_case &&
        interpretation_pattern.match?(cell_case)
    end

    # Note that this is also used for columns (by using the transposed table)
    def self.find_row_interpretations(rows, case_set, axis_interpretation, cube_size)
      row_interpretations =
        rows.map do |row|
          find_row_interpretation(row, case_set, axis_interpretation, cube_size)
        end
      # Only allow row interpretations that appear exactly once.
      counts = new_counter_hash
      row_interpretations.each { |i| counts[i] += 1 }
      row_interpretations.map { |i| counts[i] == 1 ? i : nil }
    end

    def self.new_counter_hash
      counts = {}
      counts.default = 0
      counts
    end

    def self.relevant_cases(row, case_set, cube_size)
      row.filter_map { |cell| cell.maybe_case(cube_size) }.filter { |e| case_set.match?(e) }
    end

    # Note that this is also used for columns (by using the transposed table)
    def self.find_row_interpretation(row, case_set, axis_interpretation, cube_size)
      counts = new_counter_hash
      relevant_cases(row, case_set, cube_size).each do |e|
        pattern = case_set.row_pattern(axis_interpretation, e)
        counts[pattern] += 1
      end
      max_count = counts.values.max
      keys = counts.select { |_k, v| v == max_count }.keys
      keys.length == 1 ? keys.first : nil
    end
  end
end
