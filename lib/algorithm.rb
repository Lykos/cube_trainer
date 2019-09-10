require 'move'

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

    def invert
      Algorithm.new(@moves.reverse.collect { |m| m.invert })
    end

    def +(other)
      Algorithm.new(@moves + other.moves)
    end

    # Returns the number of moves that cancel if you concat the algorithm to the right of self.
    # Doesn't support cancellation over rotations or fat move tricks.
    def cancellations(other, metric=:htm)
      Move.check_move_metric(metric)
      cancellations = 0
      0.upto([@moves.length, other.moves.length].min - 1) do |i|
        move = @moves[-i - 1]
        other_move = other.moves[i]
        if move.cancels_totally?(other_move)
          cancellations += move.move_count(metric) + other_move.move_count(metric)
        else
          if move.cancels_partially?(other_move)
            cancelled = move.cancel_partially(other_move)
            cancellations += move.move_count(metric) + other_move.move_count(metric) - cancelled.move_count(metric)
          end
          break
        end
      end
      cancellations
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
