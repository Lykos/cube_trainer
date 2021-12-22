# frozen_string_literal: true

# One alg set that is typically learned and practiced as a unit,
# e.g. the edge commutators for buffer UF.
class AlgSet < ApplicationRecord
  belongs_to :alg_spreadsheet
  has_many :algs, dependent: :destroy
  attribute :mode_type, :mode_type
  attribute :buffer, :part
  validates :alg_spreadsheet_id, presence: true
  validates :sheet_title, presence: true
  validates :mode_type, presence: true
  validates :buffer, presence: true, if: -> { mode_type&.has_buffer? }
  validate :mode_type_valid
  delegate :part_type, to: :mode_type

  private

  def buffer_valid
    mode_type.validate_buffer(buffer, errors, :buffer)
  end

  def mode_type_valid
    errors.add(:mode_type, 'has to have bounded inputs') unless mode_type.has_bounded_inputs?
  end
end
