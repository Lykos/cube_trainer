class UnreadMessagesCountChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    broadcast_to(current_user, unread_messages_count: current_user.unread_messages_count)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
