# frozen_string_literal: true

module CubeTrainer
  module Anki
    NoteInput = Struct.new(:fields, :name, :case_solution)

    NoteInputVariation = Struct.new(:fields, :name, :modified_case_solution, :image_filename, :img)
  end
end
