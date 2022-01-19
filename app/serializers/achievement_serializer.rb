# frozen_string_literal: true

# TODO: Remove now that it exists in the frontend.
class AchievementSerializer < ActiveModel::Serializer
  attributes :id, :name, :description
end
