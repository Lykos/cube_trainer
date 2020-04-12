require 'symbol_type'
require 'input_representation_type'
require 'mode_type_type'

ActiveRecord::Type.register(:symbol, SymbolType)
ActiveRecord::Type.register(:input_representation, InputRepresentationType)
ActiveRecord::Type.register(:mode_type, ModeTypeType)
