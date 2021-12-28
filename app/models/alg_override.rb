# frozen_string_literal: true

# Mode specific override for one alg that solves one particular case.
# E.g. the edge commutator [M', U2] for the case UF DF UB.
class AlgOverride < ApplicationRecord
  include AlgLike

  belongs_to :mode
  after_create :grant_alg_overrider_achievement
  delegate :user, to: :mode

  alias owning_set mode

  def grant_alg_overrider_achievement
    user.grant_achievement_if_not_granted(:alg_overrider)
  end
end
