require 'cube_trainer/training/case_set'

# Active record type for a case, e.g. one 3-cycle, one parity case,
# one twist case, one scramble etc.
# This represents the abstract case independent of its solution.
class ConcreteCaseSetType < ActiveRecord::Type::String
  extend TwistyPuzzles::Utils::StringHelper
  include TwistyPuzzles::Utils::StringHelper

  SEPARATOR = ':'

  def cast(value)
    return if value.nil?
    return value if value.is_a?(CubeTrainer::Training::ConcreteCaseSet)
    raise TypeError unless value.is_a?(String)

    CubeTrainer::Training::ConcreteCaseSet.from_raw_data(value)
  end

  def serialize(value)
    return if value.nil?
    raise TypeError unless value.is_a?(CubeTrainer::Training::ConcreteCaseSet)

    value.to_raw_data
  end
end
