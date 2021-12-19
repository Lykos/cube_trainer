class AlgSet < ApplicationRecord
  attribute :mode_type, :mode_type
  has_many :alg_set
  validates :spreadsheet_id, presence: true
  validates :sheet_id, presence: true
  validates :mode_type, presence: true
  validates :buffer, presence: true, if: -> { mode_type&.has_buffer? }
  validate :mode_type_valid
  delegate :part_type, to: :mode_type

  private

  def buffer_valid
    mode_type.validate_buffer(buffer, errors, :buffer)
  end

  def mode_type_valid
    errors.add(:mode_type, "has to have bounded inputs") unless buffer.has_bounded_inputs?
  end
end
