# frozen_string_literal: true

require 'cube_trainer/alg_name'
require 'cube_trainer/training/case_solution'

module CubeTrainer
  module Training
    # Hinter for an alg set (e.g. PLLs). Gives an alg for an alg name.
    class AlgHinter
      def initialize(hints)
        raise TypeError unless hints.is_a?(Hash)

        hints.each do |_input, hint|
          raise TypeError unless hint.is_a?(CaseSolution)
        end

        @entries = hints.to_a.freeze
        @hints = hints.transform_values { |v| [v] }
        @hints.default = []
        @hints.freeze
      end

      attr_reader :entries

      def hints(name)
        @hints[name]
      end
    end
  end
end
