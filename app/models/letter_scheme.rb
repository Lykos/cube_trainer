# frozen_string_literal: true

require 'twisty_puzzles'

# Model for letter schemes that the user created.
class LetterScheme < ApplicationRecord
  WING_LETTERING_MODES = %i[custom like_edges like_corners].freeze

  belongs_to :user
  has_many :letter_scheme_mappings, dependent: :destroy, autosave: true
  accepts_nested_attributes_for :letter_scheme_mappings
  attribute :wing_lettering_mode, :symbol
  validates :wing_lettering_mode, inclusion: WING_LETTERING_MODES

  alias mappings letter_scheme_mappings
  alias mappings= letter_scheme_mappings=
  alias mapping_ids letter_scheme_mapping_ids
  alias mapping_ids= letter_scheme_mapping_ids=

  def letter(part)
    used_part = used_part(part)
    mappings.find { |e| e.part == used_part }&.letter
  end

  def for_letter(part_type, letter)
    used_part_type = used_part(part_type)
    mappings.find { |e| e.part_type == used_part_type && e.letter == letter }&.part
  end

  private

  # Returns the part type that is actually used.
  # In some cases, it will be the same as part_type,
  # but e.g. xcenters_like_corners is true, for xcenters, this will be corners.
  def used_part_type(part_type)
    case part_type
    when TwistyPuzzles::Wing
      used_part_type_for_wing
    when TwistyPuzzles::XCenter
      xcenters_like_corners ? TwistyPuzzles::Corner : part_type
    when TwistyPuzzles::TCenter
      tcenters_like_edges ? TwistyPuzzles::Edge : part_type
    when TwistyPuzzles::Midge
      midges_like_edges ? TwistyPuzzles::Edge : part_type
    else
      part_type
    end
  end

  def used_part_type_for_wing
    case wing_lettering_mode
    when :like_edges then TwistyPuzzles::Edge
    when :like_corners then TwistyPuzzles::Corner
    when :custom then TwistyPuzzles::Wing
    else raise
    end
  end

  def used_part(part)
    used_part_type = used_part_type(part.class)
    return part if used_part_type == part.class
    return part.corresponding_part if part.corresponding_part.instance_of?(used_part_type)
    # All other cases should be handled by the previous branches.
    raise unless part.instance_of?(TwistyPuzzles::Wing) && used_part_type == TwistyPuzzles::Edge

    TwistyPuzzles::Edge.for_face_symbols(part.face_symbols)
  end
end
