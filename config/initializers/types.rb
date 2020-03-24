require 'symbol_type'
require 'cube_trainer/training/input_representation_type'

ActiveRecord::Type.register(:symbol, SymbolType)
ActiveRecord::Type.register(:input_representation, CubeTrainer::Training::InputRepresentationType)
