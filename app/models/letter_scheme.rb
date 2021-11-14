# frozen_string_literal: true

require 'twisty_puzzles'

# Model for letter schemes that the user created.
class LetterScheme < ApplicationRecord
  belongs_to :user
  has_many :letter_scheme_mappings, dependent: :destroy, autosave: true
  validates :user_id, presence: true
  accepts_nested_attributes_for :letter_scheme_mappings

  alias mappings letter_scheme_mappings
  alias mappings= letter_scheme_mappings=
  alias mapping_ids letter_scheme_mapping_ids
  alias mapping_ids= letter_scheme_mapping_ids=

  def letter(part)
    mappings.find { |e| e.part == part }&.letter
  end

  def for_letter(part_type, letter)
    mappings.find { |e| e.part_type == part_type && e.letter == letter }&.part
  end

  def to_simple
    {
      mappings: letter_scheme_mappings.map(&:to_simple)
    }
  end

  def self.speffz
    User.shared_stuff_owner.letter_scheme
  end
end
