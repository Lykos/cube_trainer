class AchievementGrant < ApplicationRecord
  attribute :achievement, :achievement
  belongs_to :user
  after_create :send_achievement_grant_message

  def to_simple
    {
      id: id,
      created_at: created_at,
      achievement: achievement.to_simple
    }
  end

  def send_achievement_grant_message
    user.messages.create!(
      title: "Achievement Unlocked: #{achievement.name}"
    )
  end
end
