class UserDumpSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :created_at, :admin, :provider, :uid
  has_one :letter_scheme, :color_scheme
  has_many :messages, :training_sessions, :achievement_grants
end
