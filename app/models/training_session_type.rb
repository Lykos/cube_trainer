# frozen_string_literal: true

require 'cube_trainer/training/human_word_learner'
require 'cube_trainer/training/human_time_learner'

# Model for training session types.
# They are basic templates which users use to create their training sessions.
# rubocop:disable Metrics/ClassLength
class TrainingSessionType
  include ActiveModel::Model
  include CubeTrainer
  include PartHelper

  SHOW_INPUT_MODES = %i[picture name scramble].freeze
  MIN_SUPPORTED_CUBE_SIZE = 2
  MAX_SUPPORTED_CUBE_SIZE = 7

  attr_accessor :key,
                :name,
                :default_cube_size,
                :show_input_modes,
                :used_training_session_types,
                :memo_time,
                :case_set

  validates :key, presence: true
  validates :name, presence: true
  validates :show_input_modes, presence: true
  validate :show_input_modes_valid

  alias memo_time? memo_time

  def default_cube_size_valid
    validate_cube_size(default_cube_size, errors, :default_cube_size)
  end

  def bounded_inputs?
    !!case_set
  end

  alias goal_badness? bounded_inputs?

  def buffer?
    case_set&.buffer?
  end

  def parity_parts?
    case_set&.parity_parts?
  end

  def parity_part_type
    parity_parts? && case_set.parity_part_type
  end

  # Takes an external errors list so it can be used for other models, too.
  def validate_cube_size(cube_size, errors, attribute = :cube_size)
    unless cube_size <= max_cube_size
      errors.add(attribute, "has to be at most #{max_cube_size} for training_session type #{name}")
    end
    unless cube_size >= min_cube_size
      errors.add(attribute, "has to be at least #{min_cube_size} for training_session type #{name}")
    end
    if cube_size.odd? && !odd_cube_size_allowed?
      errors.add(attribute, "cannot be odd for training_session type #{name}")
    end
    if cube_size.even? && !even_cube_size_allowed? # rubocop:disable Style/GuardClause
      errors.add(attribute, "cannot be even for training_session type #{name}")
    end
  end

  # Takes an external errors list so it can be used for other models, too.
  def validate_buffer(buffer, errors)
    errors.add(:buffer, "has to be a #{buffer_part_type}") unless buffer.is_a?(buffer_part_type)
  end

  # Returns a simple version for the current user that can be returned to the frontend.
  def to_simple
    {
      key: key,
      name: name,
      generator_type: generator_type,
      cube_size_spec: cube_size_spec,
      has_goal_badness: goal_badness?,
      show_input_modes: show_input_modes,
      buffers: buffers&.map { |p| part_to_simple(p) },
      has_bounded_inputs: bounded_inputs?,
      has_memo_time: memo_time?,
      stats_types: stats_types.map(&:to_simple),
      alg_sets: alg_sets.map(&:to_simple)
    }
  end

  def alg_sets
    return [] unless case_set

    AlgSet.for_concrete_case_sets(case_set.all_refinements)
  end

  def useable_training_sessions(user)
    used_training_session_types.map do |used_training_session_type|
      training_sessions =
        user.training_sessions.find_by(training_session_type: used_training_session_type)
      {
        training_sessions: training_sessions,
        purpose: used_training_session_type.key
      }
    end
  end

  def min_cube_size
    case_set ? [MIN_SUPPORTED_CUBE_SIZE, case_set.min_cube_size].max : MIN_SUPPORTED_CUBE_SIZE
  end

  def max_cube_size
    case_set ? [MAX_SUPPORTED_CUBE_SIZE, case_set.max_cube_size].min : MAX_SUPPORTED_CUBE_SIZE
  end

  def even_cube_size_allowed?
    case_set ? case_set.even_cube_size_allowed? : true
  end

  def odd_cube_size_allowed?
    case_set ? case_set.odd_cube_size_allowed? : true
  end

  def cube_size_spec
    {
      default: default_cube_size,
      min: min_cube_size,
      max: max_cube_size,
      odd_allowed: odd_cube_size_allowed?,
      even_allowed: even_cube_size_allowed?
    }
  end

  def buffer_part_type
    case_set&.buffer_part_type
  end

  def buffers
    return unless buffer?

    buffer_part_type::ELEMENTS
  end

  def show_input_modes_valid
    return if (show_input_modes - SHOW_INPUT_MODES).empty?

    errors.add(
      :show_input_modes,
      "has to be a subset of all show input training_sessions #{SHOW_INPUT_MODES.inspect}"
    )
  end

  # TODO: Remove once we don't rely on heavy caching for pictures.
  def show_input_mode_picture_for_bounded_input
    return unless show_input_modes.include?(:picture) && bounded_inputs?

    errors.add(:show_input_modes, 'cannot be :picture for unbounded inputs')
  end

  def stats_types
    StatType::ALL.select { |s| bounded_inputs? || !s.needs_bounded_inputs? }
  end

  def generator_type
    bounded_inputs? ? :case : :scramble
  end

  def show_input_modes
    bounded_inputs? ? %i[picture name] : [:scramble]
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.all
    @all ||=
      begin
        all = [
          TrainingSessionType.new(
            key: :memo_rush,
            name: 'Memo Rush',
            default_cube_size: 3,
            memo_time: true,
          ),
          TrainingSessionType.new(
            key: :corner_commutators,
            name: 'Corner Commutators',
            default_cube_size: 3,
            show_input_modes: %i[picture name],
            case_set: CaseSets::ThreeCycleSet.new(TwistyPuzzles::Corner)
          ),
          TrainingSessionType.new(
            key: :corner_parities,
            name: 'Corner Parities',
            default_cube_size: 3,
            show_input_modes: %i[picture name],
            case_set: CaseSets::ParitySet.new(TwistyPuzzles::Corner, TwistyPuzzles::Edge)
          ),
          TrainingSessionType.new(
            key: :edge_parities,
            name: 'Edge Parities',
            default_cube_size: 3,
            show_input_modes: %i[picture name],
            case_set: CaseSets::ParitySet.new(TwistyPuzzles::Edge, TwistyPuzzles::Corner)
          ),
          TrainingSessionType.new(
            key: :corner_twists_plus_parities,
            name: 'Corner 1 Twists + Parities',
            default_cube_size: 3,
            show_input_modes: %i[picture name],
            case_set: CaseSets::ParityTwistSet.new(TwistyPuzzles::Corner, TwistyPuzzles::Edge)
          ),
          TrainingSessionType.new(
            key: :edge_flips_plus_parities,
            name: 'Edge 1 Flips + Parities',
            default_cube_size: 3,
            show_input_modes: %i[picture name],
            case_set: CaseSets::ParityTwistSet.new(TwistyPuzzles::Edge, TwistyPuzzles::Corner)
          ),
          TrainingSessionType.new(
            key: :floating_2twists,
            name: 'Floating Corner 2 Twists',
            default_cube_size: 3,
            show_input_modes: %i[picture name],
            case_set: CaseSets::AbstractFloatingTwoTwistSet.new(TwistyPuzzles::Corner)
          ),
          TrainingSessionType.new(
            key: :floating_2flips,
            name: 'Floating Edge 2 Flips',
            default_cube_size: 3,
            show_input_modes: %i[picture name],
            case_set: CaseSets::AbstractFloatingTwoTwistSet.new(TwistyPuzzles::Edge)
          ),
          TrainingSessionType.new(
            key: :edge_commutators,
            name: 'Edge Commutators',
            default_cube_size: 3,
            show_input_modes: %i[picture name],
            case_set: CaseSets::ThreeCycleSet.new(TwistyPuzzles::Edge)
          ),
          TrainingSessionType.new(
            key: :wing_commutators,
            name: 'Wing Commutators',
            default_cube_size: 4,
            show_input_modes: %i[picture name],
            case_set: CaseSets::ThreeCycleSet.new(TwistyPuzzles::Wing)
          ),
          TrainingSessionType.new(
            key: :xcenter_commutators,
            name: 'X-Center Commutators',
            default_cube_size: 4,
            show_input_modes: %i[picture name],
            case_set: CaseSets::ThreeCycleSet.new(TwistyPuzzles::XCenter)
          ),
          TrainingSessionType.new(
            key: :tcenter_commutators,
            name: 'T-Center Commutators',
            default_cube_size: 5,
            show_input_modes: %i[picture name],
            case_set: CaseSets::ThreeCycleSet.new(TwistyPuzzles::TCenter)
          )
        ].freeze
        all.each(&:validate!)
        all
      end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def self.by_key
    @by_key ||= all.index_by(&:key).freeze
  end

  def self.find_by(key:)
    by_key[key.to_sym]
  end

  def self.find_by!(key:)
    find_by(key: key) || (raise ArgumentError, "Unknown training_session type #{key}.")
  end
end
# rubocop:enable Metrics/ClassLength
