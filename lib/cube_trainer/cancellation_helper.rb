require 'cube_trainer/move'
require 'cube_trainer/algorithm'
require 'cube_trainer/cube_state'

module CubeTrainer

  module CancellationHelper

    def self.swap_to_end(algorithm, index)
      new_moves = algorithm.moves.dup
      index.upto(algorithm.length - 2) do |current_index|
        obstacle_index = current_index + 1
        current = new_moves[current_index]
        obstacle = new_moves[obstacle_index]
        return nil unless current.can_swap?(obstacle)
        new_moves[current_index], new_moves[obstacle_index] = current.swap(obstacle)
      end
      Algorithm.new(new_moves)
    end
        
    # Possible variations of the algorithm where the last move has been swapped as much as allowed (e.g. D U can swap).
    def self.cancel_variants(algorithm)
      variants = []
      algorithm.moves.each_index.reverse_each do |i|
        variant = swap_to_end(algorithm, i)
        break unless variant
        variants.push(variant)
      end
      raise if variants.empty?
      variants
    end

    # Cancel this algorithm as much as possilbe
    def self.cancel(algorithm, cube_size)
      raise TypeError unless algorithm.is_a?(Algorithm)
      CubeState.check_cube_size(cube_size)
      alg = Algorithm.empty
      algorithm.moves.each do |m|
        alg = push_with_cancellation(alg, m, cube_size)
      end
      alg
    end

    def self.push_with_cancellation(algorithm, move, cube_size)
      raise TypeError unless move.is_a?(Move)
      return Algorithm.move(move) if algorithm.empty?
      cancel_variants(algorithm).map do |alg|
        Algorithm.new(alg.moves[0...-1]) + alg.moves[-1].join_with_cancellation(move, cube_size)
      end.min_by do |alg|
        # QTM is the most sensitive metric, so we use that as the highest priority for cancellations.
        # We use HTM as a second priority to make sure something like RR still gets merged into R2.
        [alg.move_count(cube_size, :qtm), alg.move_count(cube_size, :htm)]
      end
    end
    
  end
  
end
