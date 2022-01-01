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

  def commutator(casee)
    raise TypeError unless casee.is_a?(Case)
    raise ArgumentError unless casee.valid?

    maybe_commutator = algs.find { |alg| alg.casee == casee }&.commutator
    return maybe_commutator if maybe_commutator

    casee_inverse = casee.inverse
    algs.find { |alg| alg.casee == casee_inverse }&.commutator&.inverse
  end

  delegate :case_name, to: :case_set

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
