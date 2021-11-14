# frozen_string_literal: true

# Input that is used as for training for the user.
# The part of the result that is already fixed after sampling.
class Input < ApplicationRecord
  belongs_to :mode
  has_one :result, dependent: :destroy

  attribute :old_mode, :symbol
  attribute :input_representation, :input_representation

  def representation
    input_representation
  end

  validates :hostname, presence: true
  validates :input_representation, presence: true
  validates :mode_id, presence: true

  before_validation { self.hostname ||= OsHelper.hostname }

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
end
