class User < ApplicationRecord
  has_secure_password
  validates :name, presence: true, uniqueness: true
  validates :password, presence: true
  validates :password_confirmation, presence: true
  has_many :cube_trainer_training_results, dependent: :destroy
  has_many :cube_trainer_training_inputs, dependent: :destroy
end
