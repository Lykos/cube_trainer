# frozen_string_literal: true

module CubeTrainer
  module Training
    # Hinter for an alg set (e.g. PLLs). Gives an alg for an alg name.
    class AlgHinter
      def initialize(hints)
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
