require 'move'
require 'algorithm'

module CubeTrainer

  class SkewbScrambler
    
    def random_move(last_move)
      (SkewbMove::ALL - [last_move, last_move.inverse]).sample
    end

    # TODO Make it random state!
    def random_moves(n)
      raise Argumenterror unless n.is_a?(Integer) && n >= 0
      return [] if n == 0
      a = [SkewbMove::ALL.sample]
      (n-1).times do
        a.push(random_move(a[-1]))
      end
      Algorithm.new(a)
    end
    
  end
end
