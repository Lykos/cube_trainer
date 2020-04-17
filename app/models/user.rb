class User < ApplicationRecord
  has_secure_password
  validates :name, presence: true, uniqueness: true
  has_many :modes, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :achievement_grants, dependent: :destroy
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

  private

  def send_welcome_message
    messages.create!(
      title: 'Welcome',
      body: 'Welcome to Cube Trainer'
    )
  end
end
