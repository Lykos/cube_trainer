require 'types/symbol_type'
require 'types/input_representation_type'
require 'types/training_session_type_type'
require 'types/achievement_type'
require 'types/stat_type_type'
require 'types/part_type'
require 'types/case_type'
require 'types/concrete_case_set_type'

ActiveRecord::Type.register(:symbol, SymbolType)
ActiveRecord::Type.register(:input_representation, InputRepresentationType)
ActiveRecord::Type.register(:training_session_type, TrainingSessionTypeType)
ActiveRecord::Type.register(:achievement, AchievementType)
ActiveRecord::Type.register(:stat_type, StatTypeType)
ActiveRecord::Type.register(:part, PartType)
ActiveRecord::Type.register(:case, CaseType)
ActiveRecord::Type.register(:concrete_case_set, ConcreteCaseSetType)
