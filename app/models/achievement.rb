class Achievement < ApplicationRecord
  validates :name, presence: true
  validates :achievement_type, presence: true, includes: []
  has_many :users, through: :achievement_grants
end
