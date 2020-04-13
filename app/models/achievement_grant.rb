class AchievementGrant < ApplicationRecord
  belongs_to :achievement
  belongs_to :user

  def to_simple
    {
      id: id,
      achievement: achievement
    }
  end
end
