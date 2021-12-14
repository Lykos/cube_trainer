# frozen_string_literal: true

# Channel for broadcasting notifications for individual messages as they come in.
class MessageChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
