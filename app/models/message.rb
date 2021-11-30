# frozen_string_literal: true

# Model for messages a user received.
class Message < ApplicationRecord
  belongs_to :user
  validates :title, presence: true

  def to_dump
    attributes
  end
end
