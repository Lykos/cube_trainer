# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles/utils'
require 'training_session_type'

# Model for training sessions that the user created.
class TrainingSession < ApplicationRecord
  include PartHelper

  has_many :results, dependent: :destroy
  has_many :alg_overrides, dependent: :destroy
  belongs_to :user
  belongs_to :alg_set, optional: true

  attribute :training_session_type, :training_session_type
  attribute :show_input_mode, :symbol
  attribute :buffer, :part
  attr_accessor :stat_types, :verbose, :show_cube_states, :write_fixes
  attr_writer :test_comms_mode

  before_validation :set_stats
  validates :name, presence: true, uniqueness: { scope: :user }
  validates :training_session_type, presence: true
  validates :show_input_mode, presence: true, inclusion: TrainingSessionType::SHOW_INPUT_MODES
  validate :show_input_mode_valid
  validates :buffer, presence: true, if: -> { training_session_type&.buffer? }
  validates :cube_size, presence: true
  validate :cube_size_valid
  validates :exclude_algless_parts, absence: true, unless: -> { training_session_type&.buffer? }
  validate :buffer_valid, if: -> { training_session_type&.buffer? }
  validates :memo_time_s, presence: true, if: -> { training_session_type&.memo_time? }
  validate :memo_time_s_valid, if: -> { training_session_type&.memo_time? }
  has_many :stats, dependent: :destroy

  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :used_training_sessions,
                          class_name: :TrainingSession,
                          join_table: :training_session_usages,
                          association_foreign_key: :used_training_session_id
  # rubocop:enable Rails/HasAndBelongsToMany

  after_create :grant_training_session_achievement

  def case_set
    @case_set ||=
      if buffer
        training_session_type&.case_set&.refinement(buffer)
      else
        training_session_type&.case_set&.refinement
      end
  end

  def test_comms_mode
    @test_comms_mode ||= :ignore
  end

  def exclude_parts
    []
  end

  def case_name(casee)
    case_set&.case_name(casee, letter_scheme: user.letter_scheme) || casee.to_s
  end

  delegate :raw_case_name, to: :case_set

  def picture
    show_input_mode == :picture
  end

  delegate :bounded_inputs?, to: :training_session_type

  def training_cases
    return unless bounded_inputs?

    @training_cases ||= create_training_cases
  end

  def color_scheme
    @color_scheme ||= user.color_scheme || ColorScheme.wca
  end

  def solved_cube_state
    color_scheme.solved_cube_state(cube_size)
  end

  def used_training_session(training_session_type)
    used_training_sessions.find_by(training_session_type: training_session_type)
  end

  def self.find_by_user_with_preloads(user)
    user.training_sessions.preload(:alg_set, :alg_overrides)
  end

  def alg_override(casee)
    alg_overrides.find { |alg| alg.casee == casee }
  end

  def alg(casee)
    alg_override(casee) || alg_set&.alg(casee)
  end

  def setup(algorithm)
    return unless algorithm
    raise TypeError unless algorithm.is_a?(TwistyPuzzles::Algorithm)

    color_scheme.setup + algorithm.inverse
  end

  private

  def to_training_case(casee)
    a = alg(casee)
    TrainingCase.new(
      training_session: self,
      casee: casee,
      alg: a,
      setup: setup(a&.algorithm)
    )
  end

  def create_training_cases
    training_cases = case_set.cases.map { |c| to_training_case(c) }
    return without_alg_holes(training_cases) if exclude_alg_holes
    return without_algless_parts(training_cases) if exclude_algless_parts

    training_cases
  end

  def without_algless_parts(training_cases)
    cases_with_algs = training_cases.filter_map { |t| t.alg && t.casee }
    all_part_cycles = cases_with_algs.flat_map(&:part_cycles)
    buffer_part_cycles = all_part_cycles.select { |c| c.part_type == buffer.class }
    parts = buffer_part_cycles.flat_map(&:parts).uniq.flat_map(&:rotations).uniq
    parts_without_algs = buffer.class::ELEMENTS - parts
    training_cases.reject do |t|
      t.casee.part_cycles.any? do |c|
        c.part_type == buffer.class && c.contains_any_part?(parts_without_algs)
      end
    end
  end

  def without_alg_holes(training_cases)
    training_cases.select(&:alg)
  end

  def grant_training_session_achievement
    user.grant_achievement_if_not_granted(:training_session_creator)
  end

  def show_input_mode_valid
    return unless training_session_type
    return if training_session_type.show_input_modes.include?(show_input_mode)

    errors.add(:show_input_mode, 'has to be in show input modes of the training session type')
  end

  def buffer_valid
    return unless training_session_type

    training_session_type.validate_buffer(buffer, errors)
  end

  def cube_size_valid
    return unless training_session_type

    training_session_type.validate_cube_size(cube_size, errors)
  end

  def memo_time_s_valid
    errors.add(:memo_time_s, 'has to be positive') unless memo_time_s.positive?
    errors.add(:memo_time_s, 'has to be below one day') unless memo_time_s < 1.day
  end

  def num_results
    results.count
  end

  def set_stats
    return unless stat_types.present? && stats.blank?

    stat_types.each_with_index do |stat_type, index|
      stats.build(stat_type: stat_type, index: index)
    end
  end
end
