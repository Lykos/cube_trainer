# frozen_string_literal: true

module CubeTrainer
  # Helper class that figures out what rows and columns of a commutator table have in common and
  # what the interpretation of the table is.
  class CommonalityFinder
    # Represents the chosen way to interpret a table of commutators.
    class TableInterpretation
      def initialize(row_axis_interpretation, column_axis_interpretation,
                     row_interpretations, column_interpretations)
        unless [row_axis_interpretation, column_axis_interpretation].sort == [0, 1]
          raise ArgumentError
        end

        @flip_letters = [row_axis_interpretation, column_axis_interpretation] == [1, 0]
        @row_interpretations = row_interpretations
        @column_interpretations = column_interpretations
      end

      def letter_pair(row_index, col_index)
        row_interpretation = @row_interpretations[row_index]
        column_interpretation = @column_interpretations[col_index]
        return unless row_interpretation && column_interpretation

        letters = [row_interpretation, column_interpretation]
        letters.reverse! if @flip_letters
        LetterPair.new(letters)
      end
    end

    AXIS_INTERPRETATIONS = [0, 1].permutation.to_a

    # Table should be a 2D array where the entries have a method called maybe_letter_pair that
    # returns a letter pair of length 2 or nil.
    def self.interpret_table(table)
      table_interpretations = AXIS_INTERPRETATIONS.map do |row_axis_interpretation,
                                                           column_axis_interpretation|
        row_interpretations = find_row_interpretations(table, row_axis_interpretation)
        column_interpretations =
          find_row_interpretations(table.transpose, column_axis_interpretation)
        TableInterpretation.new(row_axis_interpretation, column_axis_interpretation,
                                row_interpretations, column_interpretations)
      end
      best_interpretation(table_interpretations, table)
    end

    def self.best_interpretation(table_interpretations, table)
      table_interpretations.max_by { |i| interpretation_score(i, table) }
    end

    def self.interpretation_score(table_interpretation, table)
      table.map.with_index do |row, row_index|
        row.map.with_index do |cell, col_index|
          cell_letter_pair = cell.maybe_letter_pair
          interpretation_letter_pair = table_interpretation.letter_pair(row_index, col_index)
          cell_letter_pair && cell_letter_pair == interpretation_letter_pair ? 1 : 0
        end.reduce(:+)
      end.reduce(:+)
    end

    def self.find_row_interpretations(rows, axis_interpretation)
      row_interpretations = rows.map { |row| find_row_interpretation(row, axis_interpretation) }
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

    def self.find_row_interpretation(row, axis_interpretation)
      letters = row.map(&:maybe_letter_pair).compact.map { |e| e.letters[axis_interpretation] }
      counts = new_counter_hash
      letters.each { |l| counts[l] += 1 }
      max_count = counts.values.max
      keys = counts.select { |_k, v| v == max_count }.keys
      keys.length == 1 ? keys.first : nil
    end
  end
end
