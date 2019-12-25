module CubeTrainer

  # Helper class that figures out what rows and columns of a commutator table have in common and what the meaning of the table is.
  class CommonalityFinder
    # Table should be a 2D array where the entries have a method called maybe_letter_pair that returns a letter pair or nil.
    def self.decode_table(table)
      row_meanings = find_commonalities(table)
      column_meanings = find_commonalities(table.transpose)
      counts = new_counter_hash
      (row_meanings + column_meanings).each { |m| counts[m] += 1 }
      [remove_non_uniques(row_meanings, counts),
       remove_non_uniques(column_meanings, counts)]
    end

    def remove_non_uniques(stuffs, counts)
      stuffs.map { |stuff| if counts[stuff] == 1 then stuff else nil end }
    end

    def self.find_commonalities(stuffss)
      stuffss.map { |stuffs| find_commonality(stuffs) }
    end

    def self.new_counter_hash
      counts = {}
      counts.default_proc = proc { |h, k| h[k] = 0 }
    end

    def self.find_commonality(stuffs)
      letter_pairs = stuffs.map { |s| s.maybe_letter_pair }.filter { |l| l }
      counts = new_counter_hash
      letter_pairs.map do
        |p| p.letters.each_with_index { |l, i| counts[[l, i]] += 1 }
      end
      max_count = counts.values.max
      counts.select { |k, v| v == max_count }.keys
      if keys.length == 1 then keys.first else nil end
    end
  end

end
