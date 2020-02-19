# frozen_string_literal: true

module CubeTrainer
  module Core
    # Module that makes a class that has an `apply_to` and `reverse` be able to apply temporarily.
    module ReversibleApplyable
      def apply_temporarily_to(cube_state)
        apply_to(cube_state)
        begin
          yield
        ensure
          inverse.apply_to(cube_state)
        end
      end
    end
  end
end
