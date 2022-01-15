# frozen_string_literal: true

# Model for achievement grants (i.e. which user has which achievement).
class AchievementGrant < ApplicationRecord
  attribute :achievement, :achievement
  belongs_to :user
  after_create :send_achievement_grant_message

  private

  def send_achievement_grant_message
    user.messages.create!(
      title: "Achievement Unlocked: #{achievement.name}"
    )
  end
end
