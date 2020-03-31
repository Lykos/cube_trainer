# frozen_string_literal: true

# Input that is used as for training for the user.
# The part of the result that is already fixed after sampling.
class Input < ApplicationRecord
  belongs_to :user
  attribute :mode, :symbol
  attribute :input_representation, :input_representation
end
