# frozen_string_literal: true

require 'twisty_puzzles'

# Model for letter schemes that the user created.
class LetterScheme < ApplicationRecord
  belongs_to :user
  has_many :letter_scheme_mappings, dependent: :destroy
  validates :user_id, presence: true
  alias mappings letter_scheme_mappings
  alias mappings= letter_scheme_mappings=

  def letter(part)
    letter_scheme_mappings.find { |e| e.part == part }&.letter
  end

  def for_letter(part_type, letter)
    letter_scheme_mappings.find { |e| e.part_type == part_type && e.letter == letter }&.part
  end

  def to_simple
    {
      name: name,
      mappings: letter_scheme_mappings.map(&:to_simple)
    }
  end

  def self.speffz
    User.shared_stuff_owner.letter_scheme
  end
end
