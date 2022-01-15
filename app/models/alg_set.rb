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
  delegate :owner, to: :alg_spreadsheet
  delegate :buffer, to: :case_set

  def self.for_concrete_case_sets(case_sets)
    where(case_set: case_sets).preload(:alg_spreadsheet)
  end

  private

  def alg_map
    @alg_map ||= algs.index_by(&:casee)
  end

  def commutator_internal(casee)
    alg_map[casee]&.commutator
  end
end
