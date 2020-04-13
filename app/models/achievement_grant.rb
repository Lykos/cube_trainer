class AchievementGrant < ApplicationRecord
  belongs_to :achievement
  belongs_to :user
  after_create :send_achievement_grant_message

  def to_simple
    {
      id: id,
      created_at: created_at,
      achievement: achievement
    }
  end

  def send_achievement_grant_message
    user.messages.create!(
      title: "Achievement Unlocked: #{achievement.name}"
    )
  end
end
