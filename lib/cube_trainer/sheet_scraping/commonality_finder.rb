# frozen_string_literal: true

require 'twisty_puzzles'
require 'cube_trainer/training/case_set'

module CubeTrainer
  # Helper class that figures out what rows and columns of a commutator table have in common and
  # what the interpretation of the table is.
  class CommonalityFinder
    # Represents the chosen way to interpret a table of commutators.
    class TableInterpretation
      def initialize(case_set, row_interpretations, column_interpretations)
        @case_set = case_set
        @row_interpretations = row_interpretations
        @column_interpretations = column_interpretations
      end

      def cube_size
        # TODO
        3
      end

      attr_reader :case_set

      def maybe_pattern(row_index, col_index)
        return unless @case_set

        row_interpretation = @row_interpretations[row_index]
        column_interpretation = @column_interpretations[col_index]
        return unless row_interpretation && column_interpretation

        row_interpretation & column_interpretation
      end
    end

    EMPTY_INTERPRETATION = TableInterpretation.new(nil, [].freeze, [].freeze)

    # Table should be a 2D array where the entries have a method called maybe_case that
    # returns a case.
    def self.interpret_table(table)
      case_set = find_case_set(table)
      return EMPTY_INTERPRETATION unless case_set

      interpret_table_with_case_set(table, case_set)
    end

    def self.interpret_table_with_case_set(table, case_set)
      transposed_table = table.transpose
      table_interpretations =
        [true, false].map do |flip_axes|
          row_interpretations = find_row_interpretations(table, case_set, flip_axes ? 0 : 1)
          column_interpretations =
            find_row_interpretations(transposed_table, case_set, flip_axes ? 1 : 0)
          if flip_axes
            row_interpretations, column_interpretations =
              column_interpretations,
              row_interpretations
          end
          TableInterpretation.new(
            case_set,
            row_interpretations, column_interpretations
          )
        end
      best_interpretation(table_interpretations, table)
    end

    def self.find_case_set(table)
      case_set_frequencies = new_counter_hash
      table.map do |row|
        row.map do |cell|
          count_cell_case_sets(cell, case_set_frequencies)
        end
      end
      case_set_frequencies.max_by { |_p, v| v }&.first
    end

    def self.count_cell_case_sets(cell, case_set_frequencies)
      casee = cell.maybe_case
      return unless casee

      relevant_case_sets(casee).each { |p| case_set_frequencies[p] += 1 }
    end

    def self.relevant_case_sets(casee)
      relevant_top_level_case_sets(casee).flat_map do |case_set|
        case_set.fixed_parts_refinements(casee)
      end
    end

    def self.relevant_top_level_case_sets(casee)
      Training::CASE_SETS.select { |p| p.match?(casee) }
    end

    def self.best_interpretation(table_interpretations, table)
      table_interpretations.max_by { |i| interpretation_score(i, table) }
    end

    def self.interpretation_score(table_interpretation, table)
      table.map.with_index do |row, row_index|
        row.map.with_index do |cell, col_index|
          interpretation_pattern = table_interpretation.maybe_pattern(row_index, col_index)
          cell_case = cell.maybe_case
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
    def self.find_row_interpretations(rows, case_set, axis_interpretation)
      row_interpretations =
        rows.map do |row|
          find_row_interpretation(row, case_set, axis_interpretation)
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

    def self.relevant_cases(row, case_set)
      row.filter_map(&:maybe_case).filter { |e| case_set.match?(e) }
    end

    # Note that this is also used for columns (by using the transposed table)
    def self.find_row_interpretation(row, case_set, axis_interpretation)
      counts = new_counter_hash
      relevant_cases(row, case_set).each do |e|
        pattern = case_set.row_pattern(axis_interpretation, e)
        counts[pattern] += 1
      end
      max_count = counts.values.max
      keys = counts.select { |_k, v| v == max_count }.keys
      keys.length == 1 ? keys.first : nil
    end
  end
end
