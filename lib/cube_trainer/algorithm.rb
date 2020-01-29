require 'cube_trainer/move'
require 'cube_trainer/reversible_applyable'
require 'cube_trainer/cancellation_helper'

module CubeTrainer

  class Algorithm

    def initialize(moves)
      moves.each do |m|
        raise TypeError, "#{m.inspect} is not a suitable move." unless m.is_a?(Move)
      end
      @moves = moves
    end

    EMPTY_ALGORITHM = Algorithm.new([])

    def self.empty
      EMPTY_ALGORITHM
    end

    # Creates a one move algorithm.
    def self.move(move)
      Algorithm.new([move])
    end

    attr_reader :moves
    attr_writer :inverse
    protected :inverse=

    include ReversibleApplyable
    include Comparable

    def eql?(other)
      self.class.equal?(other.class) && @moves == other.moves
    end
  
    alias == eql?
  
    def hash
      @hash ||= ([self.class] + @moves).hash
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
      @inverse ||= begin
                     alg = Algorithm.new(@moves.reverse.collect { |m| m.inverse })
                     alg.inverse = self
                     alg
                   end
    end

    def +(other)
      Algorithm.new(@moves + other.moves)
    end

    def <=>(other)
      [length, @moves] <=> [other.length, other.moves]
    end

    def has_prefix?(other)
      length >= other.length && @moves[0...other.length].zip(other.moves).all? { |m, n| m == n }
    end
 
    def has_suffix?(other)
      length >= other.length && @moves[length - other.length..-1].zip(other.moves).all? { |m, n| m == n }
    end
 
    # Returns the number of moves that cancel if you concat the algorithm to the right of self.
    # Note that the cube size is important to know which fat moves cancel
    def cancelled(cube_size)
      CancellationHelper.cancel(self, cube_size)
    end

    # Returns the number of moves that cancel if you concat the algorithm to the right of self.
    # Note that the cube size is important to know which fat moves cancel
    def cancellations(other, cube_size, metric=:htm)
      Move.check_move_metric(metric)
      cancelled = cancelled(cube_size)
      other_cancelled = other.cancelled(cube_size)
      together_cancelled = (self + other).cancelled(cube_size)
      cancelled.move_count(cube_size, metric) + other_cancelled.move_count(cube_size, metric) - together_cancelled.move_count(cube_size, metric)
    end

    # Rotates the algorithm, e.g. applying "y" to "R U" becomes "F U". Applying rotation r to alg a is equivalent to r' a r.
    # Note that this is not implemented for all moves.
    def rotate_by(rotation)
      raise TypeError unless rotation.is_a?(Rotation)
      return self if rotation.direction.is_zero?
      Algorithm.new(@moves.map { |m| m.rotate_by(rotation) })
    end

    # Mirrors the algorithm and uses the given face as the normal of the mirroring. E.g. mirroring "R U F" with "R" as the normal face, we get "L U' F'".
    def mirror(normal_face)
      raise TypeError unless normal_face.is_a?(Face)
      Algorithm.new(@moves.map { |m| m.mirror(normal_face) })
    end

    # Cube size is needed to decide whether 'u' is a slice move (like on bigger cubes) or a fat move (like on 3x3).
    def move_count(cube_size, metric=:htm)
      raise TypeError unless cube_size.is_a?(Integer)
      Move.check_move_metric(metric)
      return 0 if empty?
      @moves.map { |m| m.move_count(cube_size, metric) }.reduce(:+)
    end

    def *(factor)
      Algorithm.new(@moves * factor)
    end
  end

end
