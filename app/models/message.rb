# frozen_string_literal: true

# Model for messages a user received.
class Message < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  after_create :broadcast

  def to_dump
    attributes
  end

  def broadcast
    MessageChannel.broadcast_to(user, title: title)
  end
end
