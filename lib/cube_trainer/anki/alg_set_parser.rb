# frozen_string_literal: true

require 'twisty_puzzles'
require 'cube_trainer/anki/note_input'

module CubeTrainer
  module Anki
    # Class that parses an external alg set from a TSV coming from Anki.
    class AlgSetParser
      include TwistyPuzzles

      def initialize(cube_size)
        @cube_size = cube_size
      end

      def parse(file, alg_column, name_column, maybe_alternative_algs_column)
        CSV.read(file, col_sep: "\t").map do |row|
          name = row[name_column]
          raw_best_alg = row[alg_column]
          best_alg = parse_algorithm(raw_best_alg)
          raw_alternative_algs = if maybe_alternative_algs_column then row[maybe_alternative_algs_column] end
          alternative_algs = raw_alternative_algs.map { |raw_alg| parse_algorithm(raw_alg) }
          case_solution = CaseSolution.new(best_alg, alternative_algs)
          NoteInput.new(row, name, case_solution)
        end
      end
    end
  end
end
