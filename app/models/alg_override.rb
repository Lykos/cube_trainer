# frozen_string_literal: true

# TrainingSession specific override for one alg that solves one particular case.
# E.g. the edge commutator [M', U2] for the case UF DF UB.
class AlgOverride < ApplicationRecord
  include AlgLike

  belongs_to :training_session
  after_create :grant_alg_overrider_achievement
  delegate :user, to: :training_session

  alias owning_set training_session

  def grant_alg_overrider_achievement
    user.grant_achievement_if_not_granted(:alg_overrider)
  end
end
