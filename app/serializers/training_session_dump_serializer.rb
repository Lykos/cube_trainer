class TrainingSessionDumpSerializer < ActiveModel::Serializer
  include PartHelper
  
  attributes :id, :name, :known, :show_input_mode, :buffer, :goal_badness, :memo_time_s, :cube_size, :num_results, :exclude_algless_parts, :exclude_alg_holes, :training_session_type, :case_set, :results
  delegate :results, to: :object

  def case_set
    object.case_set.to_s
  end

  def buffer
    object.buffer ? part_to_simple(object.buffer) : nil
  end

  def training_session_type
    object.training_session_type.id
  end
end
