# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles/utils'
require 'training_session_type'
require 'cube_trainer/training/case_solution'
require 'cube_trainer/training/case_set'

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
  validates :buffer, presence: true, if: -> { training_session_type&.has_buffer? }
  validates :cube_size, presence: true, if: -> { training_session_type&.cube_size? }
  validate :cube_size_valid, if: -> { training_session_type&.cube_size? }
  validate :buffer_valid, if: -> { training_session_type&.has_buffer? }
  validates :memo_time_s, presence: true, if: -> { training_session_type&.has_memo_time? }
  validate :memo_time_s_valid, if: -> { training_session_type&.has_memo_time? }
  has_many :stats, dependent: :destroy

  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :used_training_sessions,
                          class_name: :TrainingSession,
                          join_table: :training_session_usages,
                          association_foreign_key: :used_training_session_id
  # rubocop:enable Rails/HasAndBelongsToMany

  after_create :grant_training_session_achievement

  # TODO: deprecate
  def test_comm_modes
    :fail
  end

  def generator
    @generator ||= training_session_type.generator_class.new(self)
  end

  def input_sampler
    @input_sampler ||= generator.input_sampler
  end

  delegate :input_items, to: :generator
  delegate :random_item, to: :input_sampler

  def random_case(cached_cases)
    to_case(random_item(cached_cases))
  end

  def case_set
    @case_set ||=
      if buffer
        training_session_type.case_set&.refinement(buffer)
      else
        training_session_type.case_set&.refinement
      end
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

  def case_name(casee)
    case_set&.case_name(casee, letter_scheme: user.letter_scheme) || casee.to_s
  end

  def picture
    show_input_mode == :picture
  end

  delegate :part_type, to: :training_session_type

  delegate :has_bounded_inputs?, to: :training_session_type

  delegate :parity_part_type, to: :training_session_type

  def cases
    return unless has_bounded_inputs?

    @cases ||= generator.input_items.map { |item| to_case(item) }
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
  def to_simple
    {
      id: id,
      training_session_type: training_session_type.to_simple,
      name: name,
      known: known,
      show_input_mode: show_input_mode,
      buffer: part_to_simple(buffer),
      goal_badness: goal_badness,
      memo_time_s: memo_time_s,
      cube_size: cube_size,
      num_results: results.count
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

  def commutator_override(input)
    alg_overrides.find { |alg| alg.case_key == input.case_key }&.commutator
  end

  def commutator(input)
    commutator_override(input) || alg_set&.commutator(input.case_key)
  end

  def algorithm(input)
    commutator(input)&.algorithm
  end

  def setup(input)
    alg_setup = algorithm(input)&.inverse
    color_scheme.setup + alg_setup if alg_setup
  end

  private

  def to_case(item)
    TrainingCase.new(
      training_session: self,
      casee: item.casee,
      alg: commutator(item),
      setup: setup(item)
    )
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
