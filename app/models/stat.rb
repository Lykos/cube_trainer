# frozen_string_literal: true

# Model for stats (i.e. which stat type is assigned to which training session).
class Stat < ApplicationRecord
  attribute :stat_type, :stat_type
  belongs_to :training_session

  after_create :grant_stat_creator_achievement
  delegate :user, to: :training_session

  default_scope { order(index: :asc) }

  def grant_stat_creator_achievement
    user.grant_achievement_if_not_granted(:statistician)
  end
end
