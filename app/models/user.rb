# frozen_string_literal: true

# User model.
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :omniauthable, :lockable
  include DeviseTokenAuth::Concerns::User
  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validate :validate_name_not_equal_to_email

  has_many :modes, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :achievement_grants, dependent: :destroy
  has_one :color_scheme, dependent: :destroy
  has_one :letter_scheme, dependent: :destroy
  after_create :send_welcome_message

  def to_simple
    {
      id: id,
      name: name,
      email: email,
      created_at: created_at,
      admin: admin
    }
  end

  def grant_achievement_if_not_granted(achievement_key)
    return if achievement_grants.exists?(achievement: achievement_key)

    achievement_grants.create(achievement: achievement_key)
  end

  def self.shared_stuff_owner
    User.find_by!(name: 'shared_stuff_owner')
  end

  def self.find_for_database_authentication(warden_conditions)
    username_or_email = warden_conditions[:username_or_email]
    User.find_by(name: username_or_email) || User.find_by(email: username_or_email)
  end

  def username_or_email
    @username_or_email || name || email
  end

  private

  def validate_name_not_equal_to_email
    if User.where(email: name).exists?
      errors.add(:name, 'equals the email of another user')
    end
  end

  def send_welcome_message
    messages.create!(
      title: 'Welcome',
      body: 'Welcome to Cube Trainer'
    )
  end
end
