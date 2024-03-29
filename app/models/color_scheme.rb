# frozen_string_literal: true

require 'twisty_puzzles'

# Model for color schemes that the user created.
class ColorScheme < ApplicationRecord
  belongs_to :user

  attribute :color_u, :symbol
  attribute :color_f, :symbol
  validates :color_u, :color_f, presence: true, inclusion: TwistyPuzzles::ColorScheme::WCA.colors
  validate :validate_colors_not_opposite, :validate_colors_not_same

  def to_dump
    attributes
  end

  def to_twisty_puzzles_color_scheme
    @to_twisty_puzzles_color_scheme ||=
      TwistyPuzzles::ColorScheme::WCA.turned(color_u, color_f)
  end

  def self.from_twisty_puzzles_color_scheme(color_scheme)
    new(color_u: color_scheme.color(:U), color_f: color_scheme.color(:F))
  end

  RELEVANT_ROTATION_PERMUTATIONS =
    TwistyPuzzles::Rotation::ALL_ROTATIONS.permutation(2).reject do |a, b|
      a.same_axis?(b)
    end.freeze
  ROTATION_COMBINATIONS =
    ([TwistyPuzzles::Algorithm.empty].freeze +
    TwistyPuzzles::Rotation::ALL_ROTATIONS.map { |r| TwistyPuzzles::Algorithm.move(r) } +
    RELEVANT_ROTATION_PERMUTATIONS.map { |rs| TwistyPuzzles::Algorithm.new(rs) }).freeze

  def setup
    @setup =
      begin
        state = solved_cube_state(2)
        wca_state = TwistyPuzzles::ColorScheme::WCA.solved_cube_state(2)
        ROTATION_COMBINATIONS.find do |r|
          r.apply_temporarily_to(wca_state) do |modified_wca_state|
            modified_wca_state == state
          end
        end
      end
  end

  delegate :solved_cube_state, to: :to_twisty_puzzles_color_scheme
  delegate :color, to: :to_twisty_puzzles_color_scheme

  def self.wca
    @wca ||= ColorScheme.from_twisty_puzzles_color_scheme(TwistyPuzzles::ColorScheme::WCA)
  end

  private

  def validate_colors_not_opposite
    return unless color_u && color_f
    return unless TwistyPuzzles::ColorScheme::WCA.colors.include?(color_u)
    return unless TwistyPuzzles::ColorScheme::WCA.colors.include?(color_f)
    return unless TwistyPuzzles::ColorScheme::WCA.opposite_color(color_u) == color_f

    errors.add(:color_f, "has opposite colors for faces U (#{color_u}) and F (#{color_f})")
  end

  def validate_colors_not_same
    return unless color_u && color_f
    return unless color_u == color_f

    errors.add(:color_f, "has the same colors for faces U (#{color_u}) and F (#{color_f})")
  end
end
