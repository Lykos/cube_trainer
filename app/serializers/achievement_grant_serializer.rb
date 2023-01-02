# frozen_string_literal: true

# A serialize for achievement grants that also serializes the achievement.
class AchievementGrantSerializer < ActiveModel::Serializer
  attributes :id, :created_at
  belongs_to :achievement
end
