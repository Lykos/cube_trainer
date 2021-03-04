# frozen_string_literal: true

require 'twisty_puzzles'
require 'cube_trainer/anki/note_input'
require 'cube_trainer/training/alg_hint_parser'
require 'cube_trainer/training/case_solution'

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
          raw_alternative_algs = if maybe_alternative_algs_column
                                   row[maybe_alternative_algs_column].split(Training::AlgHintParser::ALTERNATIVE_ALG_SEPARATOR)
                                 else
                                   []
                                 end
          alternative_algs = raw_alternative_algs.map { |raw_alg| parse_algorithm(raw_alg) }
          case_solution = Training::CaseSolution.new(best_alg, @cube_size, alternative_algs)
          NoteInput.new(row, name, case_solution)
        end
      end
    end
  end
end
