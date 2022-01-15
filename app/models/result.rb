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

  alias owning_set training_session

  def time
    time_s&.seconds
  end

  private

  def validate_case
    return unless casee

    errors.add(:casee, 'needs to be valid') unless casee.valid?
  end

  def grant_num_results_achievements
    achievement_id = num_results_achievement_id
    user.grant_achievement_if_not_granted(achievement_id) if achievement_id
  end

  def num_results_achievement_id
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
