require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/move'

module CubeTrainer

  class SkewbScrambler
    
    def random_move(last_move)
      (Core::FixedCornerSkewbMove::ALL - [last_move, last_move.inverse]).sample
    end

    # TODO Make it random state!
    def random_moves(n)
      raise Argumenterror unless n.is_a?(Integer) && n >= 0
      return [] if n == 0
      a = [Core::FixedCornerSkewbMove::ALL.sample]
      (n-1).times do
        a.push(random_move(a[-1]))
      end
      Core::Algorithm.new(a)
    end
    
  end
end
