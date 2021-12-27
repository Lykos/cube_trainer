# frozen_string_literal: true

# Mode specific override for one alg that solves one particular case.
# E.g. the edge commutator [M', U2] for the case UF DF UB.
class AlgOverride < ApplicationRecord
  include AlgLike

  belongs_to :mode

  alias owning_set mode
end
