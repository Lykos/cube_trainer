class Achievement < ApplicationRecord
  attribute :achievement_type, :achievement_type
  validates :name, presence: true, uniqueness: true
  validates :achievement_type, presence: true
  has_many :users, through: :achievement_grants
  has_many :achievement_grants, dependent: :destroy
  validate :param_existence

  private

  def param_existence
    if !achievement_type.has_param? && param
      errors.add(:param, "should not be set for #{achievement_type.name}")
    elsif achievement_type.has_param? && !param
      errors.add(:param, "has to be set for #{achievement_type.name}")
    end
  end
end
