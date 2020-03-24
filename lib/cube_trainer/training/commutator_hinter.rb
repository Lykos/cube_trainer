# frozen_string_literal: true

module CubeTrainer
  module Training
    # Hinter that maps letter pairs to commutators for those letter pairs.
    class CommutatorHinter
      def initialize(hints)
        @hints = hints.transform_values { |v| [v] }
      end

      def hints(letter_pair)
        @hints[letter_pair] ||=
          begin
            inverse = @hints[letter_pair.inverse]
            inverse ? inverse.map(&:inverse) : []
          end
      end
    end
  end
end
