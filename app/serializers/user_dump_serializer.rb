# frozen_string_literal: true

# Special dump serializer that serializes all data for a user.
class UserDumpSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :created_at, :admin, :provider, :uid
  has_one :letter_scheme
  has_one :color_scheme
  has_many :messages
  has_many :training_sessions, serializer: TrainingSessionDumpSerializer
  has_many :achievement_grants
end
