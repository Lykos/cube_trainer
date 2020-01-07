require 'move'
require 'reversible_applyable'

module CubeTrainer

  class Algorithm

    def initialize(moves)
      moves.each do |m|
        raise ArgumentError, "#{m.inspect} is not a suitable move." unless m.is_a?(Move)
      end
      @moves = moves
    end

    EMPTY_ALGORITHM = Algorithm.new([])

    def self.empty
      EMPTY_ALGORITHM
    end

    attr_reader :moves

    include ReversibleApplyable

    def eql?(other)
      self.class.equal?(other.class) && @moves == other.moves
    end
  
    alias == eql?
  
    def hash
      @moves.hash
    end

    def length
      @moves.length
    end

    def empty?
      @moves.empty?
    end
  
    def to_s
      @moves.join(' ')
    end

    def apply_to(cube_state)
      @moves.each { |m| m.apply_to(cube_state) }
    end

    def inverse
      Algorithm.new(@moves.reverse.collect { |m| m.inverse })
    end

    def +(other)
      Algorithm.new(@moves + other.moves)
    end

    def has_prefix?(other)
      length >= other.length && @moves[0...other.length].zip(other.moves).all? { |m, n| m == n }
    end
 
    def has_suffix?(other)
      length >= other.length && @moves[length - other.length..-1].zip(other.moves).all? { |m, n| m == n }
    end
 
    # Returns the number of moves that cancel if you concat the algorithm to the right of self.
    # Doesn't support cancellation over rotations or fat move tricks.
    def cancellations(other, metric=:htm)
      Move.check_move_metric(metric)
      Algorithm.cancellations_internal(@moves.reverse, other.moves, metric, 0, 0)
    end

    def self.switch_potential(moves, index, unmodifiable_part)
      if index < unmodifiable_part || index + 1 >= moves.length
        return 0
      end
      axis_face = moves[index].axis_face
      same_axis_moves = 1
      while index + same_axis_moves < moves.length && moves[index + same_axis_moves].axis_face.same_axis(axis_face)
        same_axis_moves += 1
      end
      same_axis_moves == 1 ? 0 : same_axis_moves
    end

    def self.split_switchable_part(moves, index, switch_potential)
      split_index = index + switch_potential
      switchable_part = moves[index...split_index]
      rest = moves[split_index..-1]
      [switchable_part, rest]
    end

    def self.cancellations_internal(reversed_moves, other_moves, metric, unmodifiable_part, other_unmodifiable_part)
      cancellations = 0
      0.upto([reversed_moves.length, other_moves.length].min - 1) do |i|
        move = reversed_moves[i]
        other_move = other_moves[i]
        if move.cancels_totally?(other_move)
          cancellations += move.move_count(metric) + other_move.move_count(metric)
        else
          # Try to switch moves around to get better cancellations
          left_switch_potential = switch_potential(reversed_moves, i, unmodifiable_part)
          right_switch_potential = switch_potential(other_moves, i, other_unmodifiable_part)
          if move.axis_face.same_axis(other_move.axis_face) && (left_switch_potential > 1 || right_switch_potential > 1)
            left_switchable_part, left_rest = split_switchable_part(reversed_moves, i, left_switch_potential)
            right_switchable_part, right_rest = split_switchable_part(other_moves, i, right_switch_potential)
            new_unmodifiable_part = [unmodifiable_part, left_switch_potential].max
            new_other_unmodifiable_part = [other_unmodifiable_part, right_switch_potential].max
            best_switched_cancellations = left_switchable_part.permutation.map do |left_switched|
              right_switchable_part.permutation.map do |right_switched|
                left = left_switched + left_rest
                right = right_switched + right_rest
                cancellations_internal(left, right, metric, new_unmodifiable_part, new_other_unmodifiable_part)
              end.max
            end.max
            return best_switched_cancellations + cancellations
          else
            # We can do one last partial cancellation
            if move.cancels_partially?(other_move)
              cancelled = move.cancel_partially(other_move)
              cancellations += move.move_count(metric) + other_move.move_count(metric) - cancelled.move_count(metric)
            end
            break
          end
        end
      end
      cancellations
    end

    # Rotates the algorithm, e.g. applying "y" to "R U" becomes "F U". Applying rotation r to alg a is equivalent to r' a r.
    # Note that this is not implemented for all moves.
    def rotate(rotation)
      raise ArgumentError unless rotation.is_a?(Rotation)
      Algorithm.new(@moves.map { |m| m.rotate(rotation) })
    end

    # Mirrors the algorithm and uses the given face as the normal of the mirroring. E.g. mirroring "R U F" with "R" as the normal face, we get "L U' F'".
    def mirror(normal_face)
      raise ArgumentError unless normal_face.is_a?(Face)
      Algorithm.new(@moves.map { |m| m.mirror(normal_face) })
    end

    def move_count(metric=:htm)
      Move.check_move_metric(metric)
      @moves.map { |m| m.move_count(metric) }.reduce(:+)
    end

    def *(factor)
      Algorithm.new(@moves * factor)
    end
  end

end
