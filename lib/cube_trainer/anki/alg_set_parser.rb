require 'cube_trainer/core/parser'
require 'cube_trainer/anki/note_input'

module CubeTrainer

  module Anki

  class AlgSetParser

    def self.parse(file, alg_column, name_column)
      CSV.read(file, :col_sep => "\t").map do |row|
        name = row[name_column]
        raw_alg = row[alg_column]
        alg = parse_algorithm(raw_alg)
        NoteInput.new(row, name, alg)
      end
    end
    
  end

  end
  
end
