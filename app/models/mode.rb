# frozen_string_literal: true

require 'cube_trainer/buffer_helper'
require 'twisty_puzzles'
require 'twisty_puzzles/utils'
require 'mode_type'

# Model for training modes that the user created.
class Mode < ApplicationRecord
  has_many :inputs, dependent: :destroy
  belongs_to :user

  attribute :mode_type, :mode_type
  attribute :show_input_mode, :symbol
  attr_accessor :stat_types, :verbose, :show_cube_states, :write_fixes
  attr_writer :test_comms_mode

  before_validation :set_stats
  validates :user_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :user }
  validates :mode_type, presence: true
  validates :show_input_mode, presence: true, inclusion: ModeType::SHOW_INPUT_MODES
  validate :show_input_mode_valid
  validates :buffer, presence: true, if: -> { mode_type.has_buffer? }
  validates :cube_size, presence: true, if: -> { mode_type.cube_size? }
  validate :cube_size_valid, if: -> { mode_type.cube_size? }
  validate :buffer_valid, if: -> { mode_type.has_buffer? }
  validates :first_parity_part, :second_parity_part,
            presence: true,
            if: -> { mode_type.has_parity_parts? }
  validate :parity_parts_valid, if: -> { mode_type.has_parity_parts? }
  validates :memo_time_s, presence: true, if: -> { mode_type.has_memo_time? }
  validates :memo_time_s, :memo_time_valid, if: -> { mode_type.has_memo_time? }
  has_many :stats, dependent: :destroy

  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :used_modes,
                          class_name: :Mode,
                          join_table: :mode_usages,
                          association_foreign_key: :used_mode_id
  # rubocop:enable Rails/HasAndBelongsToMany

  after_create :grant_mode_achievement

  # TODO: Make it configurable
  def letter_scheme
    @letter_scheme ||= TwistyPuzzles::BernhardLetterScheme.new
  end

  # TODO: Make it configurable
  def color_scheme
    TwistyPuzzles::ColorScheme::BERNHARD
  end

  # TODO: deprecate
  def test_comm_modes
    :fail
  end

  def generator
    @generator ||= mode_type.generator_class.new(self)
  end

  def input_sampler
    @input_sampler ||= generator.input_sampler
  end

  delegate :input_items, to: :generator

  delegate :random_item, to: :input_sampler

  def restrict_colors
    color_scheme.colors
  end

  def test_comms_mode
    @test_comms_mode ||= :ignore
  end

  def restrict_letters; end

  def exclude_letters
    []
  end

  def picture
    show_input_mode == :picture
  end

  delegate :part_type, to: :mode_type

  delegate :has_bounded_inputs?, to: :mode_type

  delegate :parity_part_type, to: :mode_type

  delegate :hinter, to: :generator

  def hints(input)
    hinter.hints(input.input_representation)
  end

  def parity_parts
    [first_parity_part, second_parity_part]
  end

  def solved_cube_state
    color_scheme.solved_cube_state(cube_size)
  end

  def parsed_buffer
    part_type.parse(buffer)
  end

  def used_mode(mode_type)
    used_modes.find_by(mode_type: mode_type)
  end

  private

  def grant_mode_achievement
    user.grant_achievement_if_not_granted(:mode_creator)
  end

  def show_input_mode_valid
    return if mode_type.show_input_modes.include?(show_input_mode)

    errors.add(:show_input_mode, 'has to be in show input modes of the mode type')
  end

  def buffer_valid
    errors.add(:buffer, "has to be a valid #{part_type}") unless buffer_valid?
  end

  def buffer_valid?
    part_type.parse(buffer)
  rescue ArgumentError # rubocop:disable Lint/SuppressedException
  end

  def cube_size_valid
    mode_type.validate_cube_size(cube_size, errors, :cube_size)
  end

  def memo_time_s_valid
    errors.add(:memo_time_s, 'has to be positive') unless memo_time_s.positive?
    errors.add(:memo_time_s, 'has to be below one day') unless memo_time_s < 1.day
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def parity_parts_valid
    return unless first_parity_part && second_parity_part

    unless first_parity_part < second_parity_part
      errors.add(:second_parity_part, 'has to be alphabetically after first_parity_part')
    end
    unless parity_part_valid?(first_parity_part)
      errors.add(:first_parity_part, "has to be a valid #{parity_part_type}")
    end
    unless parity_part_valid?(second_parity_part)
      errors.add(:second_parity_part, "has to be a valid #{parity_part_type}")
    end
    return unless parity_parts.all? { |p| parity_part_valid?(p) }

    first_part = parity_part_type.parse(first_parity_part)
    second_part = parity_part_type.parse(second_parity_part)
    return unless first_part.turned_equals?(second_part)

    errors.add(:second_parity_part, 'has to be a different piece from first_parity_part')
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def parity_part_valid?(parity_part)
    parity_part_type.parse(parity_part)
  rescue ArgumentError # rubocop:disable Lint/SuppressedException
  end

  def set_stats
    return unless stat_types.present? && stats.blank?

    stat_types.each_with_index do |stat_type, index|
      stats.build(stat_type: stat_type, index: index)
    end
  end
end
