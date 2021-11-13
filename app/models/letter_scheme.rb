class LetterScheme < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  has_many :letter_scheme_mapping, dependent: :destroy
  validates :name, presence: true, uniqueness: { scope: :user }

  def letter(part)
    letter_scheme_mappings.find { |e| e.part == part }&.letter
  end

  def for_letter(part_type, letter)
    letter_scheme_mappings.find { |e| e.part_type == part_type && e.letter == letter }&.part
  end
end
