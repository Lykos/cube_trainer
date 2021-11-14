# frozen_string_literal: true

# User model.
class User < ApplicationRecord
  has_secure_password
  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
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

  def color_scheme_or_wca
    color_scheme || ColorScheme.wca
  end

  private

  def send_welcome_message
    messages.create!(
      title: 'Welcome',
      body: 'Welcome to Cube Trainer'
    )
  end
end
