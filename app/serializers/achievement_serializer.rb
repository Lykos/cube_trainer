# frozen_string_literal: true

# Serializer for achievements.
class AchievementSerializer < ActiveModel::Serializer
  attributes :id, :name, :description
end
