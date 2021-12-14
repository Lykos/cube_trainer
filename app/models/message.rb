# frozen_string_literal: true

# Model for messages a user received.
class Message < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  after_create :broadcast_message, :broadcast_unread_messages_count
  after_update :broadcast_unread_messages_count, if: ->{ saved_change_to_read? }
  after_destroy :broadcast_unread_messages_count

  def to_dump
    attributes
  end

  def broadcast_unread_messages_count
    user.broadcast_unread_messages_count
  end

  def broadcast_message
    MessageChannel.broadcast_to(user, title: title)
  end
end
