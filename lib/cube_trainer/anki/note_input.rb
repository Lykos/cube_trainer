module CubeTrainer

  module Anki

    NoteInput = Struct.new(:fields, :name, :alg)

    NoteInputVariation = Struct.new(:fields, :name, :modified_alg, :image_filename, :img)

  end

end
