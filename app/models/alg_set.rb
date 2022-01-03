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

    maybe_commutator = commutator_internal(casee)
    return maybe_commutator if maybe_commutator

    commutator_internal(casee.inverse)&.inverse
  end

  delegate :case_name, to: :case_set

  def to_simple
    logger.info '#to_simple'
    {
      id: id,
      owner: alg_spreadsheet.owner,
      buffer: part_to_simple(case_set.buffer)
    }
  end

  def self.for_concrete_case_set(case_set)
    where(case_set: case_set)
  end

  private

  def commutator_internal(casee)
    algs.find { |alg| alg.casee == casee }&.commutator
  end
end
