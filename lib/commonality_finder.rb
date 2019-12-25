module CubeTrainer

  # Helper class that figures out what rows and columns of a commutator table have in common and what the interpretation of the table is.
  class CommonalityFinder

    class TableInterpretation
      def initialize(row_axis_interpretation, column_axis_interpretation, row_interpretations, column_interpretations)
        raise ArgumentError unless [0, 1] == [row_axis_interpretation, column_axis_interpretation].sort
        @flip_letters = [row_axis_interpretation, column_axis_interpretation] == [1, 0]
        @row_interpretations = row_interpretations
        @column_interpretations = column_interpretations
      end

      def letter_pair(row_index, col_index)
        row_interpretation = @row_interpretations[row_index]
        column_interpretation = @column_interpretations[col_index]
        if row_interpretation && column_interpretation
          letters = [row_interpretation, column_interpretation]
          letters.reverse! if @flip_letters
          LetterPair.new(letters)
        else
          nil
        end
      end
    end

    # Table should be a 2D array where the entries have a method called maybe_letter_pair that returns a letter pair of length 2 or nil.
    def self.interpret_table(table)
      row_interpretations = find_commonalities(table)
      column_interpretations = find_commonalities(table.transpose)
      row_axis_interpretation, column_axis_interpretation = find_axis_interpretation(row_interpretations, column_interpretations)
      filtered_row_interpretations = filter_by_axis_interpretation(row_interpretations, row_axis_interpretation)
      filtered_column_interpretations = filter_by_axis_interpretation(column_interpretations, column_axis_interpretation)
      TableInterpretation.new(row_axis_interpretation, column_axis_interpretation, filtered_row_interpretations, filtered_column_interpretations)
    end

    def self.axis_counts(interpretations)
      axis_counts = [0, 0]
      interpretations.each do |e|
        next if e.nil?
        raise "Got invalid letter pair index #{e[1]}. This comes from having letter pairs of length > 2." if e[1] > 1
        axis_counts[e[1]] += 1
      end
      axis_counts
    end

    def self.filter_by_axis_interpretation(interpretations, axis_interpretation)
      filtered_interpretations = interpretations.map { |e| if e[1] == axis_interpretation then e[0] else nil end }
      counts = new_counter_hash
      filtered_interpretations.each { |i| counts[i] += 1 }
      filtered_interpretations.map { |e| if counts[e] == 1 then e else nil end }
    end

    def self.find_axis_interpretation(row_interpretations, column_interpretations)
      row_axis_counts = axis_counts(row_interpretations)
      column_axis_counts = axis_counts(column_interpretations)
      case row_axis_counts[0] * column_axis_counts[1] <=> row_axis_counts[1] * column_axis_counts[0]
      when -1 then [1, 0]
      when 1 then [0, 1]
      else
        raise "Couldn't figure out axis interpretation."
      end
    end

    def self.find_commonalities(stuffss)
      stuffss.map { |stuffs| find_commonality(stuffs) }
    end

    def self.new_counter_hash
      counts = {}
      counts.default_proc = proc { |h, k| h[k] = 0 }
      counts
    end

    def self.find_commonality(stuffs)
      letter_pairs = stuffs.map { |s| s.maybe_letter_pair }.select { |l| l }
      counts = new_counter_hash
      letter_pairs.map do
        |p| p.letters.each_with_index { |l, i| counts[[l, i]] += 1 }
      end
      max_count = counts.values.max
      keys = counts.select { |k, v| v == max_count }.keys
      if keys.length == 1 then keys.first else nil end
    end
  end

end
