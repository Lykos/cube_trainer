# frozen_string_literal: true

class AchievementGrantSerializer < ActiveModel::Serializer
  attributes :id, :created_at
  belongs_to :achievement
end
