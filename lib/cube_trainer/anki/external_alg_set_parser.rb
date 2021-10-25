# frozen_string_literal: true

require 'twisty_puzzles'
require 'cube_trainer/anki/note_input'
require 'cube_trainer/training/alg_hint_parser'
require 'cube_trainer/training/case_solution'

module CubeTrainer
  module Anki
    # Class that parses an external alg set from a TSV coming from Anki.
    class ExternalAlgSetParser
      extend TwistyPuzzles

      def self.parse(file, alg_column, name_column)
        CSV.read(file, col_sep: "\t").map do |row|
          name = row[name_column]
          raw_alg = row[alg_column]
          alg = parse_algorithm(raw_alg)
          NoteInput.new(row, name, alg)
        end
      end
    end
  end
end
