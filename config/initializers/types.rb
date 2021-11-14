require 'symbol_type'
require 'input_representation_type'
require 'mode_type_type'
require 'achievement_type'
require 'stat_type_type'
require 'part_type'

ActiveRecord::Type.register(:symbol, SymbolType)
ActiveRecord::Type.register(:input_representation, InputRepresentationType)
ActiveRecord::Type.register(:mode_type, ModeTypeType)
ActiveRecord::Type.register(:achievement, AchievementType)
ActiveRecord::Type.register(:stat_type, StatTypeType)
ActiveRecord::Type.register(:part, PartType)
