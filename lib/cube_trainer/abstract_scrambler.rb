# frozen_string_literal: true

require 'cube_trainer/core/algorithm'

module CubeTrainer
  # Abstract class to generate scrambles.
  class AbstractScrambler
    def moves
      raise NotImplementedError
    end

    def possible_next_moves(last_move)
      raise NotImplementedError
    end

    def random_move(last_move)
      possible_next_moves(last_move).sample
    end

    # TODO: Make it random state!
    def random_moves(length)
      raise TypeError unless length.is_a?(Integer)
      raise ArgumentError if length.negative?
      return Core::Algorithm::EMPTY if length.zero?

      a = [moves.sample]
      (length - 1).times do
        a.push(random_move(a[-1]))
      end
      Core::Algorithm.new(a)
    end
  end
end
