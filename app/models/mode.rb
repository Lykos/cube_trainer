require 'cube_trainer/training/commutator_types'
require 'cube_trainer/buffer_helper'

class Mode < ApplicationRecord
  SHOW_INPUT_MODES = %i(picture name)
  TYPES = CommutatorTypes::COMMUTATOR_TYPES.keys

  attribute :type, :symbol
  validates :type, inclusion: TYPES
  attribute :show_input_mode, :symbol
  validates :show_input_mode, inclusion: SHOW_INPUT_MODES
  belongs_to :user

  # TODO: Make it configurable
  def letter_scheme
    @letter_scheme ||= BernhardLetterScheme.new
  end

  # TODO: Make it configurable
  def color_scheme
    ColorScheme::BERNHARD
  end

  def commutator_info
    CommutatorTypes::COMMUTATOR_TYPES[type]
  end

  def picture
    show_input_mode == :picture
  end

  # TODO: Get rid of this
  def legacy_mode
    BufferHelper.mode_for_options(self)
  end
end
