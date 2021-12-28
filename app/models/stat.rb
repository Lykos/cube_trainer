# frozen_string_literal: true

# Model for stats (i.e. which stat type is assigned t o which mode).
class Stat < ApplicationRecord
  attribute :stat_type, :stat_type
  belongs_to :mode

  after_create :grant_stat_creator_achievement
  delegate :user, to: :mode

  default_scope { order(index: :asc) }

  def to_simple
    {
      id: id,
      index: index,
      created_at: created_at,
      stat_type: stat_type.to_simple,
      stat_parts: stat_type.stat_parts(mode)
    }
  end

  def to_dump
    to_simple
  end

  def grant_stat_creator_achievement
    user.grant_achievement_if_not_granted(:statistician)
  end
end
