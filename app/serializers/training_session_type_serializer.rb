class TrainingSessionTypeSerializer < ActiveModel::Serializer
  include PartHelper

  attributes :id, :name, :generator_type, :cube_size_spec, :has_goal_badness, :show_input_modes, :buffers, :has_bounded_inputs, :has_memo_time, :alg_sets
  has_many :stats_types

  def has_goal_badness
    object.goal_badness?
  end

  def buffers
    object.buffers&.map { |p| part_to_simple(p) }
  end

  def has_bounded_inputs
    object.bounded_inputs?
  end

  def has_memo_time
    object.memo_time?
  end
end
