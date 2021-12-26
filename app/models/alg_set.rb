# frozen_string_literal: true

# One alg set that is typically learned and practiced as a unit,
# e.g. the edge commutators for buffer UF.
class AlgSet < ApplicationRecord
  include PartHelper

  belongs_to :alg_spreadsheet
  has_many :algs, dependent: :destroy
  attribute :mode_type, :mode_type
  attribute :buffer, :part
  validates :sheet_title, presence: true
  validates :mode_type, presence: true
  validates :buffer, presence: true, if: -> { mode_type&.has_buffer? }
  validate :mode_type_valid
  delegate :part_type, to: :mode_type

  def commutator(case_key)
    maybe_commutator = algs.find { |alg| alg.case_key == case_key }&.commutator
    return maybe_commutator if maybe_commutator

    case_key_inverse = case_key.inverse
    algs.find { |alg| alg.case_key == case_key_inverse }&.commutator&.inverse
  end

  def to_simple
    {
      id: id,
      owner: alg_spreadsheet.owner,
      buffer: part_to_simple(buffer)
    }
  end

  def self.for_mode_type(mode_type)
    all.find { |a| a.mode_type == mode_type }
  end

  private

  def buffer_valid
    mode_type.validate_buffer(buffer, errors, :buffer)
  end

  def mode_type_valid
    errors.add(:mode_type, 'has to have bounded inputs') unless mode_type.has_bounded_inputs?
  end
end
