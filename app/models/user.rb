class User < ApplicationRecord
  has_secure_password
  validates :name, presence: true, uniqueness: true
  validates :password, presence: true
  validates :password_confirmation, presence: true
  has_many :results, dependent: :destroy
  has_many :inputs, dependent: :destroy
end
