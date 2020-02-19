# frozen_string_literal: true

require 'set'

module CubeTrainer
  # Class that reads dictionaries and tries to extract useful
  # words for letter pairs from it.
  class Dict
    UNUSED_DICT_PATHS = ['/usr/share/dict/words'].freeze
    DICT_PATHS = ['/usr/share/dict/swiss'].freeze

    def words
      @words ||= read_words
    end

    def words_by_letter
      @words_by_letter ||= words.group_by { |w| w[0].downcase }
    end

    def words_for_regexp(start_letter, regexp)
      words_by_letter[start_letter].select { |w| w =~ regexp }
    end

    # Returns all words that containt the given part somewhere inside.
    def words_with_part(part)
      words.select { |w| w.include?(part) }
    end

    private

    def read_words
      lines = DICT_PATHS.collect_concat { |p| File.readlines(p) }
      words = Set[]
      lines.sort.each do |l|
        prefix_exists = 3.upto(l.length).any? { |i| words.include? l[0...i] }
        words.add(l.chomp) unless prefix_exists
      end
      words.to_a.sort
    end
  end
end
