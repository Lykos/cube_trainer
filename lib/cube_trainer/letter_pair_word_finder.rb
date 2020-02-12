# frozen_string_literal: true

module CubeTrainer
  class ProcessedTerm
    def initialize(term)
      @term = term
      @normalized_parts = term.chomp.downcase.split(/\s+/)
    end

    attr_reader :term

    def matches?(start, rest)
      correct_start = @normalized_parts.select { |p| p.start_with?(start) }
      # No matches for the start letter.
      return false if correct_start.empty?
      # Part of the start letter also matches the rest.
      return true if correct_start.any? { |p| p[1..-1].include?(rest) }
      # There are multiple correct starts and any part starts with the rest.
      return true if correct_start.length > 1 && @normalized_parts.any? { |p| p.start_with?(rest) }
      # There is one correct start and any part except for that one starts with the rest.
      if correct_start.length == 1 && @normalized_parts.any? { |p| p != correct_start.first && p.start_with?(rest) }
        return true
      end

      false
    end
  end

  class LetterPairWordFinder
    def initialize(terms)
      @processed_terms = terms.map { |t| ProcessedTerm.new(t) }
    end

    def find_term(letter_sequence)
      normalized = letter_sequence.chomp.downcase
      start = normalized[0]
      rest = normalized[1..-1]
      @processed_terms.select { |t| t.matches?(start, rest) }.map(&:term)
    end
  end
end
