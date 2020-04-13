require 'cube_trainer/buffer_helper'
require 'cube_trainer/color_scheme'
require 'cube_trainer/letter_scheme'
require 'cube_trainer/utils/array_helper'
require 'mode_type'

class Mode < ApplicationRecord
  has_many :inputs, dependent: :destroy
  belongs_to :user

  # Make this a mode type
  attribute :mode_type, :mode_type
  attribute :show_input_mode, :symbol

  validates :user_id, presence: true
  validates :name, presence: true
  validates :mode_type, presence: true
  validates :show_input_mode, presence: true, inclusion: ModeType::SHOW_INPUT_MODES
  validates :buffer, presence: true, if: ->{ mode_type.has_buffer? }
  validates :cube_size, presence: true, if: ->{ mode_type.default_cube_size }
  validate :show_input_mode_has_to_be_in_show_input_modes_of_mode_type
  validate :buffer_valid, if: ->{ mode_type.has_buffer? }

  # TODO: Make it configurable
  def letter_scheme
    @letter_scheme ||= CubeTrainer::BernhardLetterScheme.new
  end

  # TODO: Make it configurable
  def color_scheme
    CubeTrainer::ColorScheme::BERNHARD
  end

  # TODO: deprecate
  def test_comm_modes
    :fail
  end

  def generator
    @generator ||= mode_type.generator_class.new(self)
  end

  def input_sampler
    @input_sampler ||= generator.input_sampler(self)
  end

  def input_items
    generator.input_items
  end

  def random_item
    input_sampler.random_item
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

  def part_type
    mode_type.part_type
  end

  def hinter
    generator.hinter
  end

  def hints(input)
    hinter.hints(input.input_representation)
  end

  private

  def show_input_mode_has_to_be_in_show_input_modes_of_mode_type
    unless mode_type.show_input_modes.include?(show_input_mode)
      errors.add(:show_input_mode, 'has to be in show input modes of the mode type')
    end
  end

  def buffer_valid
    unless buffer_valid?
      errors.add(:buffer, "has to be a valid #{part_type}")
    end
  end

  def buffer_valid?
    begin
      part_type.parse(buffer)
    rescue ArgumentError
    end
  end
end
