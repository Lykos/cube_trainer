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
        training_session_type.case_set&.refinement(buffer)
      else
        training_session_type.case_set&.refinement
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

  def picture
    show_input_mode == :picture
  end

  delegate :bounded_inputs?, to: :training_session_type

  def training_cases
    return unless bounded_inputs?

    @training_cases ||=
      begin
        training_cases = case_set.cases.map { |c| to_training_case(c) }
        return withouth_alg_holes(training_cases) if exclude_alg_holes
        return withouth_algless_parts(training_cases) if exclude_algless_parts

        training_cases
      end
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

  # Returns a simple version for the current user that can be returned to the frontend.
  def to_simple(simple_training_session_type = training_session_type.to_simple)
    raise TypeError unless simple_training_session_type.is_a?(Hash)

    {
      id: id,
      training_session_type: simple_training_session_type,
      name: name,
      known: known,
      show_input_mode: show_input_mode,
      buffer: part_to_simple(buffer),
      goal_badness: goal_badness,
      memo_time_s: memo_time_s,
      cube_size: cube_size,
      num_results: results.count,
      training_cases: training_cases&.map(&:to_simple),
      exclude_algless_parts: exclude_algless_parts,
      exclude_alg_holes: exclude_alg_holes
    }
  end

  def self.find_by_user_with_preloads(user)
    user.training_sessions.preload(:alg_set, :alg_overrides)
  end

  # More efficient bulk `#to_simple`.
  def self.multi_to_simple(training_sessions)
    # rubocop:disable Layout/LineLength
    simple_training_session_types =
      TrainingSessionType.multi_to_simple(training_sessions.map(&:training_session_type)).index_by do |t|
        t[:key]
      end
    # rubocop:enable Layout/LineLength
    training_sessions.map do |t|
      t.to_simple(simple_training_session_types[t.training_session_type.key])
    end
  end

  def to_dump
    {
      training_session_type_key: training_session_type.key,
      name: name,
      known: known,
      show_input_mode: show_input_mode,
      buffer: PartType.new.serialize(buffer),
      goal_badness: goal_badness,
      memo_time_s: memo_time_s,
      cube_size: cube_size,
      results: results.map(&:to_dump),
      stats: stats.map(&:to_dump),
      alg_overrides: alg_overrides.map(&:to_dump),
      exclude_algless_parts: exclude_algless_parts,
      exclude_alg_holes: exclude_alg_holes
    }
  end

  def commutator_override(casee)
    alg_overrides.find { |alg| alg.casee == casee }&.commutator
  end

  def commutator(casee)
    commutator_override(casee) || alg_set&.commutator(casee)
  end

  def algorithm(casee)
    commutator(casee)&.algorithm
  end

  def setup(casee)
    alg_setup = algorithm(casee)&.inverse
    color_scheme.setup + alg_setup if alg_setup
  end

  private

  def to_training_case(casee)
    TrainingCase.new(
      training_session: self,
      casee: casee,
      alg: commutator(casee),
      setup: setup(casee)
    )
  end

  def without_algless_parts(training_cases)
    cases_with_algs = training_cases.filter_map { |t| t.alg && t.casee }
    buffer_part_cycles = cases_with_algs.part_cycles.select { |c| c.part_type == buffer.class }
    parts = buffer_part_cycles.flat_map(&:parts).uniq.flat_map(&:rotations)
    parts_without_algs = buffer.class::ELEMENTS - parts
    training_cases.reject do |c|
      c.part_cycles.any? { |c| c.part_type == buffer.class && c.parts.contains_any_part?(parts_without_alg) }
    end
  end

  def without_alg_holes(training_cases)
    training_cases.select { |t| t.alg }
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
    training_session_type.validate_buffer(buffer, errors)
  end

  def cube_size_valid
    training_session_type.validate_cube_size(cube_size, errors)
  end

  def memo_time_s_valid
    errors.add(:memo_time_s, 'has to be positive') unless memo_time_s.positive?
    errors.add(:memo_time_s, 'has to be below one day') unless memo_time_s < 1.day
  end

  def set_stats
    return unless stat_types.present? && stats.blank?

    stat_types.each_with_index do |stat_type, index|
      stats.build(stat_type: stat_type, index: index)
    end
  end
end
