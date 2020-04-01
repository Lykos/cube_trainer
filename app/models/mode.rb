require 'cube_trainer/buffer_helper'
require 'cube_trainer/color_scheme'
require 'cube_trainer/letter_scheme'
require 'cube_trainer/training/commutator_types'
require 'cube_trainer/utils/array_helper'

class Mode < ApplicationRecord
  include CubeTrainer::Utils::ArrayHelper
  include CubeTrainer::Training::CommutatorTypes

  SHOW_INPUT_MODES = %i(picture name)
  COMMUTATOR_INFOS_BY_MODE_TYPE =
    COMMUTATOR_TYPES.values.map { |v| [v.result_symbol, v] }.to_h
  MODE_TYPES = COMMUTATOR_INFOS_BY_MODE_TYPE.keys

  has_many :inputs, dependent: :destroy
  belongs_to :user

  attribute :mode_type, :symbol
  attribute :show_input_mode, :symbol

  validates :user_id, presence: true
  validates :name, presence: true
  validates :mode_type, presence: true, inclusion: MODE_TYPES
  validates :show_input_mode, presence: true, inclusion: SHOW_INPUT_MODES
  # TODO: Validate buffer and mode dependent fields

  # TODO: Make it configurable
  def letter_scheme
    @letter_scheme ||= CubeTrainer::BernhardLetterScheme.new
  end

  # TODO: Make it configurable
  def color_scheme
    CubeTrainer::ColorScheme::BERNHARD
  end

  def commutator_info
    COMMUTATOR_INFOS_BY_MODE_TYPE[mode_type]
  end

  def generator
    commutator_info.generator_class.new(self)
  end

  def verbose
    false
  end

  def restrict_colors
    color_scheme.colors
  end

  def test_comms_mode
    :ignore
  end

  def restrict_letters; end

  def exclude_letters
    []
  end

  def picture
    show_input_mode == :picture
  end

  # TODO: Get rid of this
  def legacy_mode
    CubeTrainer::BufferHelper.mode_for_options(self)
  end
end
