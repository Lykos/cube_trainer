# frozen_string_literal: true

require 'cube_trainer/alg_name'
require 'twisty_puzzles'
require 'cube_trainer/letter_pair'
require 'cube_trainer/part_cycle_sequence'
require 'cube_trainer/pao_letter_pair'
require 'cube_trainer/training/scramble'
require 'twisty_puzzles/utils'

# Result of giving one task to the learner and judging their performance.
class InputRepresentationType < ActiveRecord::Type::String
  extend TwistyPuzzles::Utils::StringHelper
  include TwistyPuzzles::Utils::StringHelper

  INPUT_REPRESENTATION_CLASSES = [
    CubeTrainer::LetterPair,
    CubeTrainer::PaoLetterPair,
    CubeTrainer::SimpleAlgName,
    CubeTrainer::CombinedAlgName,
    CubeTrainer::PartCycleSequence,
    CubeTrainer::Training::Scramble,
    TwistyPuzzles::PartCycle
  ].freeze
  INPUT_REPRESENTATION_NAME_TO_CLASS =
    INPUT_REPRESENTATION_CLASSES.index_by { |e| simple_class_name(e) }.freeze
  SEPARATOR = ':'

  def cast(value)
    return if value.nil?
    return value if INPUT_REPRESENTATION_CLASSES.any? { |c| value.is_a?(c) }
    raise TypeError unless value.is_a?(String)

    raw_clazz, raw_data = value.split(SEPARATOR, 2)
    clazz = INPUT_REPRESENTATION_NAME_TO_CLASS[raw_clazz]
    raise ArgumentError, "Unknown input representation class #{type}." unless clazz

    clazz.from_raw_data(raw_data)
  end

  def serialize(value)
    return if value.nil?
    unless INPUT_REPRESENTATION_CLASSES.any? { |c| value.is_a?(c) }
      raise TypeError, "Illegal input representation type #{value.class}."
    end

    "#{simple_class_name(value.class)}#{SEPARATOR}#{value.to_raw_data}"
  end
end
