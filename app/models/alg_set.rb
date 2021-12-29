# frozen_string_literal: true

# One alg set that is typically learned and practiced as a unit,
# e.g. the edge commutators for buffer UF.
class AlgSet < ApplicationRecord
  include PartHelper

  belongs_to :alg_spreadsheet
  has_many :algs, dependent: :destroy
  attribute :training_session_type, :training_session_type
  attribute :buffer, :part
  validates :sheet_title, presence: true
  validates :training_session_type, presence: true
  validates :buffer, presence: true, if: -> { training_session_type&.has_buffer? }
  validate :training_session_type_valid
  delegate :part_type, to: :training_session_type

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

  def self.for_training_session_type(training_session_type)
    all.find { |a| a.training_session_type == training_session_type }
  end

  private

  def buffer_valid
    training_session_type.validate_buffer(buffer, errors, :buffer)
  end

  def training_session_type_valid
    errors.add(:training_session_type, 'has to have bounded inputs') unless training_session_type.has_bounded_inputs?
  end
end
