class TrainingSessionSerializer < ActiveModel::Serializer
  include PartHelper

  attributes :id, :name, :known, :show_input_mode, :buffer, :goal_badness, :memo_time_s,
             :cube_size, :num_results, :exclude_algless_parts, :exclude_alg_holes, :generator_type
  has_many :training_cases
  has_many :stats

  def buffer
    object.buffer ? part_to_simple(object.buffer) : nil
  end

  def generator_type
    object.training_session_type.generator_type
  end
end
