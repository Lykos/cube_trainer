# frozen_string_literal: true

require 'cube_trainer/alg_name'
require 'cube_trainer/core/parser'
require 'cube_trainer/letter_pair'
require 'cube_trainer/letter_pair_sequence'
require 'cube_trainer/pao_letter_pair'
require 'cube_trainer/training/scramble'
require 'cube_trainer/utils/string_helper'

# Result of giving one task to the learner and judging their performance.
class InputRepresentationType < ActiveRecord::Type::String
  extend CubeTrainer::Utils::StringHelper
  include CubeTrainer::Utils::StringHelper

  INPUT_REPRESENTATION_CLASSES = [
    CubeTrainer::LetterPair,
    CubeTrainer::PaoLetterPair,
    CubeTrainer::SimpleAlgName,
    CubeTrainer::CombinedAlgName,
    CubeTrainer::LetterPairSequence,
    CubeTrainer::Training::Scramble
  ].freeze
  INPUT_REPRESENTATION_NAME_TO_CLASS =
    INPUT_REPRESENTATION_CLASSES.map { |e| [simple_class_name(e), e] }.to_h.freeze
  SEPARATOR = ':'

  def cast(value)
    return if value.nil?
    return value if INPUT_REPRESENTATION_CLASSES.any? { |c| value.is_a?(c) }
    raise TypeError unless value.is_a?(String)

    type, raw_data = value.split(SEPARATOR, 2)
    clazz = INPUT_REPRESENTATION_NAME_TO_CLASS[type]
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
