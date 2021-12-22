# frozen_string_literal: true

# One alg that solves one particular case. E.g. the edge commutator [M', U2] for the case UF DF UB.
class Alg < ApplicationRecord
  belongs_to :alg_set
  validates :alg, presence: true
  validates :case_key, presence: true
end
