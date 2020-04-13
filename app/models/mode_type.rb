require 'cube_trainer/training/commutator_hint_parser'
require 'cube_trainer/training/commutator_sets'
require 'cube_trainer/training/cube_scrambles'
require 'cube_trainer/training/human_word_learner'
require 'cube_trainer/training/human_time_learner'
require 'cube_trainer/training/letters_to_word'
require 'cube_trainer/training/alg_sets'

class ModeType
  include ActiveModel::Model
  include CubeTrainer::Training

  SHOW_INPUT_MODES = %i(picture name)

  attr_accessor :name,
                :generator_class,
                :learner_type,
                :default_cube_size,
                :has_buffer,
                :has_goal_badness,
                :show_input_modes,
                :used_mode_types

  alias has_goal_badness? has_goal_badness
  alias has_buffer? has_buffer

  # Returns a simple version for the current user that can be returned to the frontend.
  def to_simple(user=nil)
    {
      name: name,
      learner_type: learner_type,
      default_cube_size: default_cube_size,
      has_buffer: has_buffer?,
      has_goal_badness: has_goal_badness?,
      show_input_modes: show_input_modes,
      buffers: buffers
    }.tap { |r| r[:useable_modes] = useable_modes(user) if user }
  end

  def useable_modes(user)
    used_mode_types.map do |used_mode_type|
      {
        modes: user.modes.find_by(mode_type: used_mode_type),
        purpose: used_mode_type.name
      }
    end
  end

  def part_type
    generator_class::PART_TYPE
  end

  def buffers
    return unless has_buffer?

    part_type::ELEMENTS.map(&:to_s)
  end

  ALL = [
    ModeType.new(
      name: :memo_rush,
      generator_class: CubeScrambles,
      learner_type: :memo_rush,
      default_cube_size: 3,
      has_buffer: false,
      has_goal_badness: false,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :corner_commutators,
      generator_class: CornerCommutators,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :corner_parities_ul_ub,
      generator_class: CornerParities,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :corner_twists_plus_parities_ul_ub,
      generator_class: CornerTwistsPlusParities,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :floating_2twists,
      generator_class: FloatingCorner2Twists,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :corner_3twists,
      generator_class: Corner3Twists,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :floating_2twists_and_corner_3twists,
      generator_class: FloatingCorner2TwistsAnd3Twists,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :floating_2flips,
      generator_class: FloatingEdgeFlips,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: false,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :edge_commutators,
      generator_class: EdgeCommutators,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :wing_commutators,
      generator_class: WingCommutators,
      learner_type: :case_time,
      default_cube_size: 4,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :xcenter_commutators,
      generator_class: XCenterCommutators,
      learner_type: :case_time,
      default_cube_size: 4,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :tcenter_commutators,
      generator_class: TCenterCommutators,
      learner_type: :case_time,
      default_cube_size: 5,
      has_buffer: true,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :letters_to_word,
      generator_class: LettersToWord,
      learner_type: :word,
      has_buffer: false,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :oh_plls_by_name,
      generator_class: Plls,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: false,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :plls_by_name,
      generator_class: Plls,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: false,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :oh_colls_by_name,
      generator_class: Colls,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: false,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :colls_by_name,
      generator_class: Colls,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: false,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    ),
    ModeType.new(
      name: :olls_plus_cp,
      generator_class: OllsPlusCp,
      learner_type: :case_time,
      default_cube_size: 3,
      has_buffer: false,
      has_goal_badness: true,
      show_input_modes: SHOW_INPUT_MODES
    )
  ].freeze
end
