# frozen_string_literal: true

# One alg set that is typically learned and practiced as a unit,
# e.g. the edge commutators for buffer UF.
class AlgSet < ApplicationRecord
  include PartHelper

  belongs_to :alg_spreadsheet
  has_many :algs, dependent: :destroy
  attribute :case_set, :concrete_case_set
  validates :sheet_title, presence: true
  validates :case_set, presence: true

  def commutator(case_key)
    maybe_commutator = algs.find { |alg| alg.case_key == case_key }&.commutator
    return maybe_commutator if maybe_commutator

    case_key_inverse = case_key.inverse
    algs.find { |alg| alg.case_key == case_key_inverse }&.commutator&.inverse
  end

  def to_simple
    {
      id: id,
      owner: alg_spreadsheet.owner
    }
  end

  def self.for_concrete_case_set(case_set)
    all.find { |a| a.case_set == case_set }
  end
end
