# frozen_string_literal: true

require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/move'

module CubeTrainer
  class SkewbScrambler
    def random_move(last_move)
      (Core::FixedCornerSkewbMove::ALL - [last_move, last_move.inverse]).sample
    end

    # TODO: Make it random state!
    def random_moves(length)
      raise Argumenterror unless length.is_a?(Integer) && length >= 0
      return [] if length == 0

      a = [Core::FixedCornerSkewbMove::ALL.sample]
      (length - 1).times do
        a.push(random_move(a[-1]))
      end
      Core::Algorithm.new(a)
    end
  end
end
