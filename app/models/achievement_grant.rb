class AchievementGrant < ApplicationRecord
  belongs_to :achievement
  belongs_to :user

  def to_simple
    {
      id: id,
      created_at: created_at,
      achievement: achievement
    }
  end
end
