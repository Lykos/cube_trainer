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
  validates :invert_wing_letter, inclusion: [nil, false], if: -> { wing_lettering_mode == :custom }

  alias mappings letter_scheme_mappings
  alias mappings= letter_scheme_mappings=
  alias mapping_ids letter_scheme_mapping_ids
  alias mapping_ids= letter_scheme_mapping_ids=

  def letter(part)
    used_part = used_part(part)
    mappings.find { |e| e.part == used_part }&.letter
  end

  def for_letter(part_type, letter)
    used_part_type = used_part_type(part_type)
    used_part = mappings.find { |e| e.part_type == used_part_type && e.letter == letter }&.part
    return unless used_part

    original_part(part_type, used_part)
  end

  private

  # Returns the part type that is actually used.
  # In some cases, it will be the same as part_type,
  # but e.g. xcenters_like_corners is true, for xcenters, this will be corners.
  def used_part_type(part_type)
    if part_type == TwistyPuzzles::Wing
      used_part_type_for_wing
    elsif part_type == TwistyPuzzles::XCenter
      xcenters_like_corners ? TwistyPuzzles::Corner : part_type
    elsif part_type == TwistyPuzzles::TCenter
      tcenters_like_edges ? TwistyPuzzles::Edge : part_type
    elsif part_type == TwistyPuzzles::Midge
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
    return used_wing_corner(part) if part.instance_of?(TwistyPuzzles::Wing) && used_part_type == TwistyPuzzles::Corner
    return part.corresponding_part if part.corresponding_part.instance_of?(used_part_type)
    # All other cases should be handled by the previous branches.
    raise unless used_part_type == TwistyPuzzles::Edge

    used_edge(part)
  end

  def original_part(original_part_type, used_part)
    return used_part if used_part.instance_of?(original_part_type)
    if used_part.instance_of?(TwistyPuzzles::Corner) && original_part_type == TwistyPuzzles::Wing
      return original_wing_for_corner(used_part)
    end
    if original_part_type::ELEMENTS.first.corresponding_part.instance_of?(used_part.class)
      return original_part_type::ELEMENTS.find { |p| p.corresponding_part == used_part }
    end
    # All other cases should be handled by the previous branches.
    raise unless used_part.instance_of?(TwistyPuzzles::Edge)

    original_part_for_edge(original_part_type, used_part)
  end

  def used_wing_corner(part)
    corner = part.corresponding_part
    invert_wing_letter ? corner.rotate_by(1) : corner
  end

  def original_wing_for_corner(used_corner)
    used_corner = used_corner.rotate_by(-1) if invert_wing_letter
    TwistyPuzzles::Wing::ELEMENTS.find { |p| p.corresponding_part == used_corner }
  end

  def used_edge(part)
    raise unless part.instance_of?(TwistyPuzzles::Wing) || part.instance_of?(TwistyPuzzles::Midge)

    edge_face_symbols = part.face_symbols.dup
    edge_face_symbols.reverse! if part.instance_of?(TwistyPuzzles::Wing) && invert_wing_letter
    TwistyPuzzles::Edge.for_face_symbols(edge_face_symbols)
  end

  def original_part_for_edge(original_part_type, used_edge)
    raise unless [TwistyPuzzles::Wing, TwistyPuzzles::Midge].include?(original_part_type)

    original_face_symbols = used_edge.face_symbols.dup
    original_face_symbols.reverse! if original_part_type == TwistyPuzzles::Wing && invert_wing_letter
    original_part_type.for_face_symbols(original_face_symbols)
  end
end
