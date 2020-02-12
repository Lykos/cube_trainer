# frozen_string_literal: true

module CubeTrainer
  class Algorithm
    def shrink
      Algorithm.new(@moves.shrink)
    end
  end
end
