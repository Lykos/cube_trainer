# frozen_string_literal: true

# Model for messages a user received.
class Message < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  after_create :broadcast_message
  after_update :broadcast_read_message

  def to_dump
    attributes
  end

  def broadcast_read_message
    user.broadcast_unread_messages_count if saved_change_to_read?
  end

  def broadcast_message
    MessageChannel.broadcast_to(user, title: title)
    user.broadcast_unread_messages_count
  end
end
