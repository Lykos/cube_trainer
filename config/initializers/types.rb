require 'types/symbol_type'
require 'types/input_representation_type'
require 'types/training_session_type_type'
require 'types/achievement_type'
require 'types/part_type'
require 'types/case_type'
require 'types/concrete_case_set_type'

Rails.autoloaders.log!

ActiveRecord::Type.register(:symbol, Types::SymbolType)
ActiveRecord::Type.register(:input_representation, Types::InputRepresentationType)
ActiveRecord::Type.register(:training_session_type, Types::TrainingSessionTypeType)
ActiveRecord::Type.register(:achievement, Types::AchievementType)
ActiveRecord::Type.register(:part, Types::PartType)
ActiveRecord::Type.register(:case, Types::CaseType)
ActiveRecord::Type.register(:concrete_case_set, Types::ConcreteCaseSetType)
