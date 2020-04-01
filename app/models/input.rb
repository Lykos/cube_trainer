# frozen_string_literal: true

# Input that is used as for training for the user.
# The part of the result that is already fixed after sampling.
class Input < ApplicationRecord
  belongs_to :mode
  has_one :result, dependent: :destroy
  attribute :legacy_mode, :symbol
  attribute :input_representation, :input_representation

  validates :input_representation, presence: true  

  before_validation { self.hostname ||= self.class.current_hostname }
end
