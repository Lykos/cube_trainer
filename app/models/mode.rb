# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles/utils'
require 'mode_type'
require 'cube_trainer/training/case_solution'

# Model for training modes that the user created.
class Mode < ApplicationRecord
  include PartHelper

  has_many :results, dependent: :destroy
  belongs_to :user

  attribute :mode_type, :mode_type
  attribute :show_input_mode, :symbol
  attribute :buffer, :part
  attr_accessor :stat_types, :verbose, :show_cube_states, :write_fixes
  attr_writer :test_comms_mode

  before_validation :set_stats
  validates :user_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :user }
  validates :mode_type, presence: true
  validates :show_input_mode, presence: true, inclusion: ModeType::SHOW_INPUT_MODES
  validate :show_input_mode_valid
  validates :buffer, presence: true, if: -> { mode_type&.has_buffer? }
  validates :cube_size, presence: true, if: -> { mode_type&.cube_size? }
  validate :cube_size_valid, if: -> { mode_type&.cube_size? }
  validate :buffer_valid, if: -> { mode_type&.has_buffer? }
  validates :first_parity_part, :second_parity_part,
            presence: true,
            if: -> { mode_type&.has_parity_parts? }
  validate :parity_parts_valid, if: -> { mode_type&.has_parity_parts? }
  validates :memo_time_s, presence: true, if: -> { mode_type&.has_memo_time? }
  validate :memo_time_s_valid, if: -> { mode_type&.has_memo_time? }
  has_many :stats, dependent: :destroy

  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :used_modes,
                          class_name: :Mode,
                          join_table: :mode_usages,
                          association_foreign_key: :used_mode_id
  # rubocop:enable Rails/HasAndBelongsToMany

  after_create :grant_mode_achievement

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

  def random_case(cached_cases)
    to_case(random_item(cached_cases))
  end

  def restrict_parts
    part_type::ELEMENTS
  end

  def test_comms_mode
    @test_comms_mode ||= :ignore
  end

  def exclude_parts
    []
  end

  def maybe_apply_letter_scheme(input_case_key)
    return input_case_key unless user.letter_scheme

    mode_type.maybe_apply_letter_scheme(user.letter_scheme, input_case_key)
  end

  def picture
    show_input_mode == :picture
  end

  delegate :part_type, to: :mode_type

  delegate :has_bounded_inputs?, to: :mode_type

  delegate :parity_part_type, to: :mode_type

  delegate :hinter, to: :generator

  def hints(input)
    hinter.hints(input.case_key)
  end

  def cases
    return unless has_bounded_inputs?

    @cases ||= generator.input_items.map { |item| to_case(item) }
  end

  def parity_parts
    [first_parity_part, second_parity_part]
  end

  def color_scheme
    @color_scheme ||= user.color_scheme || ColorScheme.wca
  end

  def solved_cube_state
    color_scheme.solved_cube_state(cube_size)
  end

  def used_mode(mode_type)
    used_modes.find_by(mode_type: mode_type)
  end

  # Returns a simple version for the current user that can be returned to the frontend.
  def to_simple
    {
      id: id,
      mode_type: mode_type.to_simple,
      name: name,
      known: known,
      show_input_mode: show_input_mode,
      buffer: part_to_simple(buffer),
      goal_badness: goal_badness,
      memo_time_s: memo_time_s,
      cube_size: cube_size
    }
  end

  def to_dump
    to_simple.merge!(
      {
        results: results.map(&:to_dump),
        stats: stats.map(&:to_dump)
      }
    )
  end

  def commutator(input)
    hints = hints(input)
    hints.find { |i| i.is_a?(TwistyPuzzles::Commutator) } ||
      hints.find { |i| i.is_a?(CubeTrainer::Training::CaseSolution) }&.best_alg
  end

  def algorithm(input)
    hints(input).find { |i| i.is_a?(TwistyPuzzles::Algorithm) } ||
      commutator(input)&.algorithm
  end

  def setup(input)
    alg_setup = algorithm(input)&.inverse
    color_scheme.setup + alg_setup if alg_setup
  end

  private

  def to_case(item)
    Case.new(
      mode: self,
      hints: hints(item),
      case_key: item.case_key,
      setup: setup(item)
    )
  end

  def grant_mode_achievement
    user.grant_achievement_if_not_granted(:mode_creator)
  end

  def show_input_mode_valid
    return unless mode_type
    return if mode_type.show_input_modes.include?(show_input_mode)

    errors.add(:show_input_mode, 'has to be in show input modes of the mode type')
  end

  def buffer_valid
    mode_type.validate_buffer(buffer, errors, :buffer)
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
