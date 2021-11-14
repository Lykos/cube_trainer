# frozen_string_literal: true

require 'twisty_puzzles'

# Model for color schemes that the user created.
class ColorScheme < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  TwistyPuzzles::CubeConstants::FACE_SYMBOLS.each do |f|
    attribute f.downcase, :symbol
    validates f.downcase, presence: true
  end
  validate :colors_valid

  def to_twisty_puzzles_color_scheme
    @to_twisty_puzzles_color_scheme ||=
      begin
        color_mappings =
          TwistyPuzzles::CubeConstants::FACE_SYMBOLS.index_with do |f|
            color(f)
          end
        TwistyPuzzles::ColorScheme.new(color_mappings)
      end
  end

  def self.from_twisty_puzzles_color_scheme(color_scheme)
    color_mappings =
      TwistyPuzzles::CubeConstants::FACE_SYMBOLS.index_with do |f|
        color_scheme.color(f)
      end
    color_mappings.transform_keys!(&:downcase)
    new(**color_mappings)
  end

  delegate :solved_cube_state, to: :to_twisty_puzzles_color_scheme

  def colors_valid
    TwistyPuzzles::CubeConstants::FACE_SYMBOLS.each { |f| color_valid(f.downcase) }
  end

  def color(face_symbol)
    method(face_symbol.downcase).call
  end

  def color_valid(face_symbol)
    c = color(face_symbol)
    return unless TwistyPuzzles::ColorScheme::RESERVED_COLORS.include?(c)

    errors.add(face_symbol, "has reserved color #{c}")
  end

  def self.wca
    @wca ||= ColorScheme.from_twisty_puzzles_color_scheme(TwistyPuzzles::ColorScheme::WCA)
  end
end
