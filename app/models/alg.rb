# frozen_string_literal: true

# One alg that solves one particular case.
# E.g. the edge commutator [M', U2] for the case UF DF UB.
class Alg < ApplicationRecord
  include AlgLike

  belongs_to :alg_set

  alias owning_set alg_set
end
