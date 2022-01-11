# frozen_string_literal: true

module CaseSets
  # A concrete case set like edge 3-cycles for buffer UF.
  # This is used for training and parsing alg sets.
  class ConcreteCaseSet
    def self.class_by_name(name)
      @classes_by_name ||= [
        BufferedThreeCycleSet, BufferedParitySet, BufferedParityTwistSet,
        ConcreteFloatingTwoTwistSet
      ].index_by do |e|
        simple_class_name(e)
      end.freeze
      @classes_by_name[name]
    end

    extend TwistyPuzzles::Utils::StringHelper
    include CaseSetHelper
    include TwistyPuzzles::Utils::StringHelper

    SEPARATOR = ':'

    def buffer
      raise NotImplementedError, "buffer is not implemented for #{self}"
    end

    def row_pattern(refinement_index, casee)
      raise NotImplementedError
    end

    def to_raw_data
      ([simple_class_name(self.class)] + to_raw_data_parts_internal).join(SEPARATOR)
    end

    def self.from_raw_data(raw_data)
      raw_clazz, *raw_data_parts = raw_data.split(SEPARATOR)
      clazz = class_by_name(raw_clazz)
      raise ArgumentError, "Unknown concrete case set class #{raw_clazz}" unless clazz

      clazz.from_raw_data_parts(raw_data_parts)
    end

    def to_raw_data_parts_internal
      raise NotImplementedError
    end

    def case_name(casee, letter_scheme: nil)
      raise NotImplementedError
    end

    # Stricter version of `match?` that doesn't necessarily match equivalent cases.
    # E.g. for 3 cycles, this only matches cases that start with the right buffer
    # and doesn't match
    def strict_match?(casee)
      raise NotImplementedError
    end

    # Creates an equivalent case that fulfills `strict_match?`.
    def create_strict_matching(casee)
      raise NotImplementedError
    end

    def default_cube_size
      raise NotImplementedError
    end

    def cases
      raise NotImplementedError
    end
  end
end
