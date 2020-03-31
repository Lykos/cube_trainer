# frozen_string_literal: true

# Result of giving one task to the learner and judging their performance.
# TODO Migrate from LegacyResult in lib/ to this.
class Result < ApplicationRecord
  belongs_to :user

  POSITIVE_INTEGER = {
    only_integer: true,
    greater_than_or_equal_to: 0
  }.freeze

  attribute :mode, :symbol
  attribute :input_representation, :input_representation

  validates :user_id, presence: true
  validates :hostname, presence: true
  validates :mode, presence: true
  validates :time_s, numericality: { greater_than: 0 }
  validates :input_representation, presence: true
  validates :failed_attempts, numericality: POSITIVE_INTEGER
  validates :success, presence: true
  validates :num_hints, numericality: POSITIVE_INTEGER

  before_validation { self.hostname ||= self.class.current_hostname }

  def self.from_partial(mode, created_at, partial_result, input_representation)
    new(
      mode: mode,
      time_s: partial_result.time_s,
      input_representation: input_representation,
      failed_attempts: partial_result.failed_attempts,
      word: partial_result.word,
      success: partial_result.success,
      num_hints: partial_result.num_hints,
      created_at: created_at
    )
  end

  def self.from_input_and_partial(input, partial_result)
    new(
      mode: input.mode,
      input_representation: input.input_representation,
      created_at: input.created_at,
      time_s: partial_result.time_s,
      failed_attempts: partial_result.failed_attempts,
      word: partial_result.word,
      success: partial_result.success,
      num_hints: partial_result.num_hints
    )
  end

  def self.modes
    select(:mode).distinct.map(&:mode)
  end

  def time
    time_s&.seconds
  end
end
