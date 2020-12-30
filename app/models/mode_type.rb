# frozen_string_literal: true

require 'cube_trainer/training/commutator_hint_parser'
require 'cube_trainer/training/commutator_sets'
require 'cube_trainer/training/cube_scrambles'
require 'cube_trainer/training/human_word_learner'
require 'cube_trainer/training/human_time_learner'
require 'cube_trainer/training/letters_to_word'
require 'cube_trainer/training/alg_sets'

# Model for mode types. They are basic templates which users use to create their training modes.
# rubocop:disable Metrics/ClassLength
class ModeType
  include ActiveModel::Model
  include CubeTrainer::Training

  SHOW_INPUT_MODES = %i[picture name].freeze
  MAX_SUPPORTED_CUBE_SIZE = 7

  attr_accessor :key,
                :name,
                :generator_class,
                :learner_type,
                :default_cube_size,
                :has_buffer,
                :has_goal_badness,
                :show_input_modes,
                :used_mode_types,
                :has_parity_parts

  validates :key, presence: true
  validates :name, presence: true
  validates :generator_class, presence: true
  validates :learner_type, presence: true
  validates :show_input_modes, presence: true
  validates :default_cube_size, presence: true, if: :cube_size?
  validate :default_cube_size_valid, if: :cube_size?

  alias has_goal_badness? has_goal_badness
  alias has_buffer? has_buffer
  alias has_parity_parts? has_parity_parts

  def default_cube_size_valid
    validate_cube_size(default_cube_size, errors, :default_cube_size)
  end

  # Takes an external errors list so it can be used for other models, too.
  def validate_cube_size(cube_size, errors, attribute)
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

  # Returns a simple version for the current user that can be returned to the frontend.
  def to_simple(user = nil)
    {
      key: key,
      name: name,
      learner_type: learner_type,
      cube_size_spec: cube_size_spec,
      has_goal_badness: has_goal_badness?,
      show_input_modes: show_input_modes,
      buffers: buffers
    }.tap { |r| r[:useable_modes] = useable_modes(user) if user }
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

    part_type::ELEMENTS.map(&:to_s)
  end

  ALL = [
    ModeType.new(
      key: :memo_rush,
      name: 'Memo Rush',
      generator_class: CubeScrambles,
      learner_type: :memo_rush,
      default_cube_size: 3,
      has_buffer: false,
      has_goal_badness: false,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      key: :corner_commutators,
      name: 'Corner Commutators',
      generator_class: CornerCommutators,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      key: :corner_parities,
      name: 'Corner Parities',
      generator_class: CornerParities,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES,
      has_parity_parts: true
    ),
    ModeType.new(
      key: :corner_twists_plus_parities,
      name: 'Corner 1 Twists + Parities',
      generator_class: CornerTwistsPlusParities,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES,
      has_parity_parts: true
    ),
    ModeType.new(
      key: :floating_2twists,
      name: 'Floating Corner 2 Twists',
      generator_class: FloatingCorner2Twists,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      key: :corner_3twists,
      name: 'Corner 3 Twists',
      generator_class: Corner3Twists,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      key: :floating_2twists_and_corner_3twists,
      name: 'Floating Corner 2 Twists + 3 Twists',
      generator_class: FloatingCorner2TwistsAnd3Twists,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      key: :floating_2flips,
      name: 'Floating Edge 2 Flips',
      generator_class: FloatingEdgeFlips,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: false,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      key: :edge_commutators,
      name: 'Edge Commutators',
      generator_class: EdgeCommutators,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      key: :wing_commutators,
      name: 'Wing Commutators',
      generator_class: WingCommutators,
      learner_type: :case_time,
      default_cube_size: 4,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      key: :xcenter_commutators,
      name: 'X-Center Commutators',
      generator_class: XCenterCommutators,
      learner_type: :case_time,
      default_cube_size: 4,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      key: :tcenter_commutators,
      name: 'T-Center Commutators',
      generator_class: TCenterCommutators,
      learner_type: :case_time,
      default_cube_size: 5,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      key: :letters_to_word,
      name: 'Letters To Word',
      generator_class: LettersToWord,
      learner_type: :word,
      has_buffer: false,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      key: :plls,
      name: 'PLLs',
      generator_class: Plls,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: false,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      key: :colls,
      name: 'COLLs',
      generator_class: Colls,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: false,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      key: :olls_plus_cp,
      name: 'OLLs + CP',
      generator_class: OllsPlusCp,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: false,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    )
  ].freeze
  ALL.each(&:validate!)
  BY_KEY = ALL.index_by(&:key).freeze

  def self.find_by(key:)
    BY_KEY[key.to_sym]
  end

  def self.find_by!(key:)
    find_by(key: key) || (raise ArgumentError, "Unknown mode type #{key}.")
  end
end
# rubocop:enable Metrics/ClassLength
