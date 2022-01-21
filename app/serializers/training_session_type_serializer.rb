# frozen_string_literal: true

# Serializer for training session types.
class TrainingSessionTypeSerializer < ActiveModel::Serializer
  include PartHelper

  attributes :id, :name, :generator_type, :cube_size_spec, :has_goal_badness, :show_input_modes,
             :buffers, :has_bounded_inputs, :has_memo_time
  has_many :alg_sets

  def buffers
    object.buffers&.map { |p| part_to_simple(p) }
  end

  # rubocop:disable Naming/PredicateName
  def has_goal_badness
    object.goal_badness?
  end

  def has_bounded_inputs
    object.bounded_inputs?
  end

  def has_memo_time
    object.memo_time?
  end
  # rubocop:enable Naming/PredicateName
end
