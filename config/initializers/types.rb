require 'cube_trainer/types/symbol_type'
require 'cube_trainer/types/input_representation_type'
require 'cube_trainer/types/training_session_type_type'
require 'cube_trainer/types/achievement_type'
require 'cube_trainer/types/part_type'
require 'cube_trainer/types/parts_type'
require 'cube_trainer/types/case_type'
require 'cube_trainer/types/concrete_case_set_type'

ActiveRecord::Type.register(:symbol, CubeTrainer::Types::SymbolType)
ActiveRecord::Type.register(:input_representation, CubeTrainer::Types::InputRepresentationType)
ActiveRecord::Type.register(:training_session_type, CubeTrainer::Types::TrainingSessionTypeType)
ActiveRecord::Type.register(:achievement, CubeTrainer::Types::AchievementType)
ActiveRecord::Type.register(:part, CubeTrainer::Types::PartType)
ActiveRecord::Type.register(:parts, CubeTrainer::Types::PartsType)
ActiveRecord::Type.register(:case, CubeTrainer::Types::CaseType)
ActiveRecord::Type.register(:concrete_case_set, CubeTrainer::Types::ConcreteCaseSetType)
