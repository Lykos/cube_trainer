# frozen_string_literal: true

# User model.
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :omniauthable, :lockable
  include DeviseTokenAuth::Concerns::User

  validate :validate_name_not_equal_to_email
  validates :name, uniqueness: true
  validates :email, uniqueness: true

  has_many :training_sessions, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :achievement_grants, dependent: :destroy
  has_one :color_scheme, dependent: :destroy
  has_one :letter_scheme, dependent: :destroy
  after_create :send_welcome_message

  def admin?
    admin
  end

  def grant_achievement_if_not_granted(achievement_id)
    return if achievement_grants.exists?(achievement: achievement_id)

    achievement_grants.create(achievement: achievement_id)
  end

  def unread_messages_count
    messages.where(read: false).count
  end

  def broadcast_unread_messages_count
    UnreadMessagesCountChannel.broadcast_to(self, unread_messages_count: unread_messages_count)
  rescue Redis::CannotConnectError => e
    Rails.logger.error "Broadcasting message failed: #{e}"
  end

  private

  def validate_name_not_equal_to_email
    return unless name
    return unless User.exists?(email: name)

    errors.add(:name, 'equals the email of another user')
  end

  def send_welcome_message
    messages.create!(
      title: 'Welcome',
      body: 'Welcome to Cube Trainer'
    )
  end
end
