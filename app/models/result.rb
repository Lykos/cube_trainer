# frozen_string_literal: true

# Result of giving one task to the user and judging their performance.
# E.g. the time it took to execute one algorithm for a case shown to them.
class Result < ApplicationRecord
  POSITIVE_INTEGER = {
    only_integer: true,
    greater_than_or_equal_to: 0
  }.freeze

  belongs_to :training_session

  attribute :casee, :case
  validates :time_s, presence: true, numericality: { greater_than: 0 }
  validates :failed_attempts, numericality: POSITIVE_INTEGER
  validates :success, inclusion: [true, false]
  validates :num_hints, numericality: POSITIVE_INTEGER
  validates :casee, presence: true
  validate :validate_case
  after_create :grant_num_results_achievements
  delegate :user, to: :training_session

  def to_simple
    {
      id: id,
      case_key: CaseType.new.serialize(casee),
      case_name: training_session.case_name(casee),
      time_s: time_s,
      failed_attempts: failed_attempts,
      word: word,
      success: success,
      num_hints: num_hints,
      created_at: created_at
    }
  end

  def to_dump
    {
      case_key: CaseType.new.serialize(casee),
      time_s: time_s,
      failed_attempts: failed_attempts,
      word: word,
      success: success,
      num_hints: num_hints,
      created_at: created_at
    }
  end

  def time
    time_s&.seconds
  end

  private

  def validate_case
    return unless casee

    errors.add(:casee, 'needs to be valid') unless casee.valid?
  end

  def grant_num_results_achievements
    achievement_key = num_results_achievement_key
    user.grant_achievement_if_not_granted(achievement_key) if achievement_key
  end

  def num_results_achievement_key
    if training_session.results.count >= 100_000
      :wizard
    elsif training_session.results.count >= 10_000
      :professional
    elsif training_session.results.count >= 1000
      :addict
    elsif training_session.results.count >= 100
      :enthusiast
    end
  end
end
