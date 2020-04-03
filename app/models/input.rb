# frozen_string_literal: true

# Input that is used as for training for the user.
# The part of the result that is already fixed after sampling.
class Input < ApplicationRecord
  belongs_to :mode
  has_one :result, dependent: :destroy

  attribute :old_mode, :symbol
  attribute :input_representation, :input_representation

  validates :hostname, presence: true
  validates :input_representation, presence: true
  validates :mode_id, presence: true

  before_validation { self.hostname ||= OsHelper.hostname }
end
