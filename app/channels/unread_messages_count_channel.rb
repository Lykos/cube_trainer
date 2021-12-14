# frozen_string_literal: true

# Channel for broadcasting notifications for the number of unread messages as it changes.
# Broadcasts the lastest value on subscription for convenience.
class UnreadMessagesCountChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    broadcast_to(current_user, unread_messages_count: current_user.unread_messages_count)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
