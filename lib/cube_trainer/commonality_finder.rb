# frozen_string_literal: true

require 'twisty_puzzles'

module CubeTrainer
  # Helper class that figures out what rows and columns of a commutator table have in common and
  # what the interpretation of the table is.
  class CommonalityFinder
    # Represents the chosen way to interpret a table of commutators.
    class TableInterpretation
      def initialize(
        buffer,
        row_axis_interpretation, column_axis_interpretation,
        row_interpretations, column_interpretations
      )
        unless [row_axis_interpretation, column_axis_interpretation].sort == [0, 1]
          raise ArgumentError
        end

        @buffer = buffer
        @flip_parts = [row_axis_interpretation, column_axis_interpretation] == [1, 0]
        @row_interpretations = row_interpretations
        @column_interpretations = column_interpretations
      end

      def part_cycle(row_index, col_index)
        row_interpretation = @row_interpretations[row_index]
        column_interpretation = @column_interpretations[col_index]
        return unless row_interpretation && column_interpretation

        parts = [row_interpretation, column_interpretation]
        parts.reverse! if @flip_parts
        TwistyPuzzles::PartCycle.new([@buffer] + parts)
      end
    end

    AXIS_INTERPRETATIONS = [0, 1].permutation.to_a

    # Table should be a 2D array where the entries have a method called maybe_part_cycle that
    # returns a part pair of length 2 or nil.
    # TODO: Automatically figure out buffer.
    def self.interpret_table(table, buffer)
      transposed_table = table.transpose
      table_interpretations =
        AXIS_INTERPRETATIONS.map do |row_axis_interpretation, column_axis_interpretation|
          row_interpretations = find_row_interpretations(table, buffer, row_axis_interpretation)
          column_interpretations =
            find_row_interpretations(transposed_table, buffer, column_axis_interpretation)
          TableInterpretation.new(
            buffer,
            row_axis_interpretation, column_axis_interpretation,
            row_interpretations, column_interpretations
          )
        end
      best_interpretation(table_interpretations, table)
    end

    def self.best_interpretation(table_interpretations, table)
      table_interpretations.max_by { |i| interpretation_score(i, table) }
    end

    def self.interpretation_score(table_interpretation, table)
      table.map.with_index do |row, row_index|
        row.map.with_index do |cell, col_index|
          cell_part_cycle = cell.maybe_part_cycle
          interpretation_part_cycle = table_interpretation.part_cycle(row_index, col_index)
          cell_part_cycle && cell_part_cycle == interpretation_part_cycle ? 1 : 0
        end.sum
      end.sum
    end

    def self.find_row_interpretations(rows, buffer, axis_interpretation)
      row_interpretations = rows.map { |row| find_row_interpretation(row, buffer, axis_interpretation) }
      # Only allow row interpretations that appear exactly once.
      counts = new_counter_hash
      row_interpretations.each { |i| counts[i] += 1 }
      row_interpretations.map { |i| counts[i] == 1 ? i : nil }
    end

    def self.new_counter_hash
      counts = {}
      counts.default_proc = proc { |h, k| h[k] = 0 }
      counts
    end

    def self.find_row_interpretation(row, buffer, axis_interpretation)
      relevant_part_cycles = row.filter_map(&:maybe_part_cycle).filter { |e| e.parts[0] == buffer }
      parts = relevant_part_cycles.map { |e| e.parts[axis_interpretation + 1] }
      counts = new_counter_hash
      parts.each { |l| counts[l] += 1 }
      max_count = counts.values.max
      keys = counts.select { |_k, v| v == max_count }.keys
      keys.length == 1 ? keys.first : nil
    end
  end
end
