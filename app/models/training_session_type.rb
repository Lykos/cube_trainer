# frozen_string_literal: true

require 'cube_trainer/training/commutator_sets'
require 'cube_trainer/training/commutator_hint_parser'
require 'cube_trainer/training/cube_scrambles'
require 'cube_trainer/training/human_word_learner'
require 'cube_trainer/training/human_time_learner'
require 'cube_trainer/training/letters_to_word'
require 'cube_trainer/training/alg_sets'
require 'cube_trainer/letter_pair'

# Model for mode types. They are basic templates which users use to create their training modes.
# rubocop:disable Metrics/ClassLength
class TrainingSessionType
  include ActiveModel::Model
  include CubeTrainer
  include PartHelper

  SHOW_INPUT_MODES = %i[picture name].freeze
  MAX_SUPPORTED_CUBE_SIZE = 7
  LETTER_SCHEME_MODES = %i[buffer_plus_2_parts simple].freeze

  attr_accessor :key,
                :name,
                :generator_class,
                :learner_type,
                :default_cube_size,
                :has_buffer,
                :has_bounded_inputs,
                :has_goal_badness,
                :show_input_modes,
                :used_mode_types,
                :has_parity_parts,
                :has_memo_time,
                :has_setup,
                :letter_scheme_mode

  validates :key, presence: true
  validates :name, presence: true
  validates :generator_class, presence: true
  validates :learner_type, presence: true
  validates :show_input_modes, presence: true
  validate :show_input_modes_valid
  validates :default_cube_size, presence: true, if: :cube_size?
  validate :default_cube_size_valid, if: :cube_size?
  validates :letter_scheme_mode, inclusion: LETTER_SCHEME_MODES, if: :letter_scheme_mode

  alias has_bounded_inputs? has_bounded_inputs
  alias has_goal_badness? has_goal_badness
  alias has_buffer? has_buffer
  alias has_parity_parts? has_parity_parts
  alias has_memo_time? has_memo_time
  alias has_setup? has_setup

  def default_cube_size_valid
    validate_cube_size(default_cube_size, errors, :default_cube_size)
  end

  # Takes an external errors list so it can be used for other models, too.
  def validate_cube_size(cube_size, errors, attribute = :cube_size)
    unless cube_size <= max_cube_size
      errors.add(attribute, "has to be at most #{max_cube_size} for mode type #{name}")
    end
    unless cube_size >= min_cube_size
      errors.add(attribute, "has to be at least #{min_cube_size} for mode type #{name}")
    end
    if cube_size.odd? && !odd_cube_size_allowed?
      errors.add(attribute, "cannot be odd for mode type #{name}")
    end
    if cube_size.even? && !even_cube_size_allowed? # rubocop:disable Style/GuardClause
      errors.add(attribute, "cannot be even for mode type #{name}")
    end
  end

  # Takes an external errors list so it can be used for other models, too.
  def validate_buffer(buffer, errors)
    errors.add(:buffer, "has to be a #{part_type}") unless buffer.is_a?(part_type)
  end

  # Takes an external errors list so it can be used for other models, too.
  def validate_case_key(case_key, errors)
    unless case_key.is_a?(TwistyPuzzles::PartCycle)
      errors.add(
        :case_key,
        'has to be a part cycle'
      ) && return
    end

    errors.add(:case_key, "has to be a #{part_type}") unless case_key.part_type == part_type
    unless case_key.length == cycle_length
      errors.add(
        :case_key,
        "has to have length #{cycle_length}"
      )
    end
    errors.add(:case_key, 'cannot twist') unless case_key.twist.zero?
  end

  # TODO: Support more than 3 cycles
  def cycle_length
    3
  end

  # TODO: Refactor
  def maybe_apply_letter_scheme(letter_scheme, case_key)
    # TODO: Remove this backwards compatibility logic if possible.
    return case_key if case_key.is_a?(LetterPair)

    letters = letters_internal(letter_scheme, case_key)
    return case_key if letters.any?(&:nil?)

    LetterPair.new(letters)
  end

  def letters_internal(letter_scheme, case_key)
    case letter_scheme_mode
    when :buffer_plus_2_parts
      raise TypeError unless case_key.is_a?(TwistyPuzzles::PartCycle)
      raise ArgumentError unless case_key.length == 3

      [
        letter_scheme.letter(case_key.parts[1]),
        letter_scheme.letter(case_key.parts[2])
      ]
    when :simple
      raise TypeError unless case_key.is_a?(TwistyPuzzles::PartCycle)

      case_key.parts.map { |p| letter_scheme.letter(p) }
    else
      [nil]
    end
  end

  # Returns a simple version for the current user that can be returned to the frontend.
  def to_simple(_user = nil)
    {
      key: key,
      name: name,
      learner_type: learner_type,
      cube_size_spec: cube_size_spec,
      has_goal_badness: has_goal_badness?,
      show_input_modes: show_input_modes,
      buffers: buffers&.map { |p| part_to_simple(p) },
      has_bounded_inputs: has_bounded_inputs?,
      has_memo_time: has_memo_time?,
      has_setup: has_setup?,
      stats_types: stats_types.map(&:to_simple),
      alg_sets: alg_sets.map(&:to_simple)
    }
  end

  def alg_sets
    AlgSet.where(mode_type: self)
  end

  def useable_modes(user)
    used_mode_types.map do |used_mode_type|
      {
        modes: user.modes.find_by(mode_type: used_mode_type),
        purpose: used_mode_type.key
      }
    end
  end

  def cube_size_spec
    return unless cube_size?

    {
      default: default_cube_size,
      min: min_cube_size,
      max: max_cube_size,
      odd_allowed: odd_cube_size_allowed?,
      even_allowed: even_cube_size_allowed?
    }
  end

  def min_cube_size
    parity_part_type_min_cube_size =
      parity_part_type ? parity_part_type.min_cube_size : -Float::INFINITY

    maximal_min_cube_size = [part_type.min_cube_size, parity_part_type_min_cube_size].max
    wrong_parity?(maximal_min_cube_size) ? maximal_min_cube_size + 1 : maximal_min_cube_size
  end

  def max_cube_size
    parity_part_type_max_cube_size =
      parity_part_type ? parity_part_type.max_cube_size : Float::INFINITY

    minimal_max_cube_size = [
      part_type.max_cube_size,
      parity_part_type_max_cube_size,
      MAX_SUPPORTED_CUBE_SIZE
    ].min
    wrong_parity?(minimal_max_cube_size) ? minimal_max_cube_size - 1 : minimal_max_cube_size
  end

  def wrong_parity?(cube_size)
    (cube_size.even? && !even_cube_size_allowed?) || (cube_size.odd? && !odd_cube_size_allowed?)
  end

  def odd_cube_size_allowed?
    part_type.exists_on_odd_cube_sizes? &&
      (parity_part_type.nil? || parity_part_type.exists_on_odd_cube_sizes?)
  end

  def even_cube_size_allowed?
    part_type.exists_on_even_cube_sizes? &&
      (parity_part_type.nil? || parity_part_type.exists_on_even_cube_sizes?)
  end

  def part_type
    generator_class.const_defined?(:PART_TYPE) ? generator_class::PART_TYPE : nil
  end

  alias cube_size? part_type

  def parity_part_type
    generator_class.const_defined?(:PARITY_PART_TYPE) ? generator_class::PARITY_PART_TYPE : nil
  end

  def buffers
    return unless has_buffer?

    part_type::ELEMENTS
  end

  def show_input_modes_valid
    return if (show_input_modes - SHOW_INPUT_MODES).empty?

    errors.add(
      :show_input_modes,
      "has to be a subset of all show input modes #{SHOW_INPUT_MODES.inspect}"
    )
  end

  # TODO: Remove once we don't rely on heavy caching for pictures.
  def show_input_mode_picture_for_bounded_input
    return unless show_input_modes.include?(:picture) && has_bounded_inputs?

    errors.add(:show_input_modes, 'cannot be :picture for unbounded inputs')
  end

  def stats_types
    StatType::ALL.select { |s| has_bounded_inputs? || !s.needs_bounded_inputs? }
  end

  # rubocop:disable Metrics/MethodLength
  def self.all
    @all ||=
      begin
        all = [
          TrainingSessionType.new(
            key: :memo_rush,
            name: 'Memo Rush',
            generator_class: Training::CubeScrambles,
            learner_type: :memo_rush,
            default_cube_size: 3,
            has_buffer: false,
            has_goal_badness: false,
            show_input_modes: [:name],
            has_bounded_inputs: false,
            has_memo_time: true,
            has_setup: true
          ),
          TrainingSessionType.new(
            key: :corner_commutators,
            name: 'Corner Commutators',
            generator_class: Training::CornerCommutators,
            learner_type: :case_time,
            default_cube_size: 3,
            has_buffer: true,
            has_goal_badness: true,
            show_input_modes: SHOW_INPUT_MODES,
            letter_scheme_mode: :buffer_plus_2_parts,
            has_bounded_inputs: true
          ),
          TrainingSessionType.new(
            key: :corner_parities,
            name: 'Corner Parities',
            generator_class: Training::CornerParities,
            learner_type: :case_time,
            default_cube_size: 3,
            has_buffer: true,
            has_goal_badness: true,
            show_input_modes: SHOW_INPUT_MODES,
            letter_scheme_mode: :buffer_plus_2_parts,
            has_bounded_inputs: true,
            has_parity_parts: true
          ),
          TrainingSessionType.new(
            key: :corner_twists_plus_parities,
            name: 'Corner 1 Twists + Parities',
            generator_class: Training::CornerTwistsPlusParities,
            learner_type: :case_time,
            default_cube_size: 3,
            has_buffer: true,
            has_goal_badness: true,
            show_input_modes: SHOW_INPUT_MODES,
            has_bounded_inputs: true,
            has_parity_parts: true
          ),
          TrainingSessionType.new(
            key: :floating_2twists,
            name: 'Floating Corner 2 Twists',
            generator_class: Training::FloatingCorner2Twists,
            learner_type: :case_time,
            default_cube_size: 3,
            has_buffer: false,
            has_goal_badness: true,
            show_input_modes: SHOW_INPUT_MODES,
            has_bounded_inputs: true
          ),
          TrainingSessionType.new(
            key: :corner_3twists,
            name: 'Corner 3 Twists',
            generator_class: Training::Corner3Twists,
            learner_type: :case_time,
            default_cube_size: 3,
            has_buffer: true,
            has_goal_badness: true,
            show_input_modes: SHOW_INPUT_MODES,
            has_bounded_inputs: true,
            letter_scheme_mode: :buffer_plus_2_parts
          ),
          TrainingSessionType.new(
            key: :floating_2twists_and_corner_3twists,
            name: 'Floating Corner 2 Twists + 3 Twists',
            generator_class: Training::FloatingCorner2TwistsAnd3Twists,
            learner_type: :case_time,
            default_cube_size: 3,
            has_buffer: true,
            has_goal_badness: true,
            show_input_modes: SHOW_INPUT_MODES,
            has_bounded_inputs: true
          ),
          TrainingSessionType.new(
            key: :floating_2flips,
            name: 'Floating Edge 2 Flips',
            generator_class: Training::FloatingEdgeFlips,
            learner_type: :case_time,
            default_cube_size: 3,
            has_buffer: false,
            has_goal_badness: true,
            show_input_modes: SHOW_INPUT_MODES,
            has_bounded_inputs: true,
            letter_scheme_mode: :simple
          ),
          TrainingSessionType.new(
            key: :edge_commutators,
            name: 'Edge Commutators',
            generator_class: Training::EdgeCommutators,
            learner_type: :case_time,
            default_cube_size: 3,
            has_buffer: true,
            has_goal_badness: true,
            show_input_modes: SHOW_INPUT_MODES,
            has_bounded_inputs: true,
            letter_scheme_mode: :buffer_plus_2_parts
          ),
          TrainingSessionType.new(
            key: :wing_commutators,
            name: 'Wing Commutators',
            generator_class: Training::WingCommutators,
            learner_type: :case_time,
            default_cube_size: 4,
            has_buffer: true,
            has_goal_badness: true,
            show_input_modes: SHOW_INPUT_MODES,
            has_bounded_inputs: true,
            letter_scheme_mode: :buffer_plus_2_parts
          ),
          TrainingSessionType.new(
            key: :xcenter_commutators,
            name: 'X-Center Commutators',
            generator_class: Training::XCenterCommutators,
            learner_type: :case_time,
            default_cube_size: 4,
            has_buffer: true,
            has_goal_badness: true,
            show_input_modes: SHOW_INPUT_MODES,
            has_bounded_inputs: true,
            letter_scheme_mode: :buffer_plus_2_parts
          ),
          TrainingSessionType.new(
            key: :tcenter_commutators,
            name: 'T-Center Commutators',
            generator_class: Training::TCenterCommutators,
            learner_type: :case_time,
            default_cube_size: 5,
            has_buffer: true,
            has_goal_badness: true,
            show_input_modes: SHOW_INPUT_MODES,
            has_bounded_inputs: true,
            letter_scheme_mode: :buffer_plus_2_parts
          )
        ].freeze
        all.each(&:validate!)
        all
      end
  end
  # rubocop:enable Metrics/MethodLength

  def self.by_key
    @by_key ||= all.index_by(&:key).freeze
  end

  def self.find_by(key:)
    by_key[key.to_sym]
  end

  def self.find_by!(key:)
    find_by(key: key) || (raise ArgumentError, "Unknown mode type #{key}.")
  end
end
# rubocop:enable Metrics/ClassLength
