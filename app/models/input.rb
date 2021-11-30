# frozen_string_literal: true

# Input that is used as for training for the user.
# The part of the result that is already fixed after sampling.
class Input < ApplicationRecord
  belongs_to :mode
  has_one :result, dependent: :destroy

  attribute :input_representation, :input_representation

  def representation
    input_representation
  end

  validates :input_representation, presence: true
  validates :mode_id, presence: true

  def to_simple_result
    {
      id: result.id,
      mode: mode.to_simple,
      input_representation: mode.maybe_apply_letter_scheme(input_representation).to_s,
      time_s: result.time_s,
      failed_attempts: result.failed_attempts,
      success: result.success,
      num_hints: result.num_hints,
      created_at: created_at
    }
  end

  def to_dump
    {
      id: id,
      result: result&.to_dump,
      input_representation: input_representation.to_s,
      created_at: created_at,
      result: result&.to_dump
    }
  end
end
