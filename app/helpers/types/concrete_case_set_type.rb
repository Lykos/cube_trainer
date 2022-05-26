# frozen_string_literal: true

module Types

  # Active record type for a case, e.g. one 3-cycle, one parity case,
  # one twist case, one scramble etc.
  # This represents the abstract case independent of its solution.
  class ConcreteCaseSetType < ActiveRecord::Type::String
    extend TwistyPuzzles::Utils::StringHelper
    include TwistyPuzzles::Utils::StringHelper

    SEPARATOR = ':'

    def cast(value)
      return if value.nil?
      return value if value.is_a?(CaseSets::ConcreteCaseSet)
      raise TypeError unless value.is_a?(String)

      CaseSets::ConcreteCaseSet.from_raw_data(value)
    end

    def serialize(value)
      return if value.nil?

      # We do this indirection for validation.
      value = cast(value) if value.is_a?(String)
      unless value.is_a?(CaseSets::ConcreteCaseSet)
        raise TypeError, "expected #{CaseSets::ConcreteCaseSet}, got #{value}::#{value.class}"
      end

      value.to_raw_data
    end
  end

end
