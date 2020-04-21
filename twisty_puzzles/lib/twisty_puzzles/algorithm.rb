# frozen_string_literal: true

require 'twisty_puzzles/abstract_move'
require 'twisty_puzzles/reversible_applyable'
require 'twisty_puzzles/cancellation_helper'
require 'twisty_puzzles/cube_state'
require 'twisty_puzzles/compiled_cube_algorithm'
require 'twisty_puzzles/compiled_skewb_algorithm'

module TwistyPuzzles
  
    # Represents a sequence of moves that can be applied to puzzle states.
    class Algorithm
      include ReversibleApplyable
      include Comparable

      def initialize(moves)
        moves.each do |m|
          raise TypeError, "#{m.inspect} is not a suitable move." unless m.is_a?(AbstractMove)
        end
        @moves = moves
      end

      EMPTY = Algorithm.new([])

      # Creates a one move algorithm.
      def self.move(move)
        Algorithm.new([move])
      end

      attr_reader :moves

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

      def inspect
        "Algorithm(#{self})"
      end

      def apply_to(cube_state)
        case cube_state
        when SkewbState
          compiled_for_skewb.apply_to(cube_state)
        when CubeState
          compiled_for_cube(cube_state.n).apply_to(cube_state)
        else
          raise TypeError, "Unsupported cube state class #{cube_state.class}."
        end
      end

      def inverse
        @inverse ||=
          begin
            alg = self.class.new(@moves.reverse.map(&:inverse))
            alg.inverse = self
            alg
          end
      end

      def +(other)
        self.class.new(@moves + other.moves)
      end

      def <=>(other)
        [length, @moves] <=> [other.length, other.moves]
      end

      # Returns the cancelled version of the given algorithm.
      # Note that the cube size is important to know which fat moves cancel
      def cancelled(cube_size)
        CancellationHelper.cancel(self, cube_size)
      end

      # Returns the number of moves that cancel if you concat the algorithm to the right of self.
      # Note that the cube size is important to know which fat moves cancel
      def cancellations(other, cube_size, metric = :htm)
        CubeState.check_cube_size(cube_size)
        AbstractMove.check_move_metric(metric)
        cancelled = cancelled(cube_size)
        other_cancelled = other.cancelled(cube_size)
        together_cancelled = (self + other).cancelled(cube_size)
        cancelled.move_count(cube_size, metric) +
          other_cancelled.move_count(cube_size, metric) -
          together_cancelled.move_count(cube_size, metric)
      end

      # Rotates the algorithm, e.g. applying "y" to "R U" becomes "F U".
      # Applying rotation r to alg a is equivalent to r' a r.
      # Note that this is not implemented for all moves.
      def rotate_by(rotation)
        raise TypeError unless rotation.is_a?(Rotation)
        return self if rotation.direction.zero?

        self.class.new(@moves.map { |m| m.rotate_by(rotation) })
      end

      # Mirrors the algorithm and uses the given face as the normal of the mirroring.
      # E.g. mirroring "R U F" with "R" as the normal face, we get "L U' F'".
      def mirror(normal_face)
        raise TypeError unless normal_face.is_a?(Face)

        self.class.new(@moves.map { |m| m.mirror(normal_face) })
      end

      # Cube size is needed to decide whether 'u' is a slice move (like on bigger cubes) or a
      # fat move (like on 3x3).
      def move_count(cube_size, metric = :htm)
        raise TypeError unless cube_size.is_a?(Integer)

        AbstractMove.check_move_metric(metric)
        return 0 if empty?

        @moves.map { |m| m.move_count(cube_size, metric) }.reduce(:+)
      end

      def *(other)
        raise TypeError unless other.is_a?(Integer)
        raise ArgumentError if other.negative?

        self.class.new(@moves * other)
      end

      def compiled_for_skewb
        @compiled_for_skewb ||= CompiledSkewbAlgorithm.for_moves(@moves)
      end

      def compiled_for_cube(cube_size)
        (@compiled_for_cube ||= {})[cube_size] ||=
          CompiledCubeAlgorithm.for_moves(cube_size, @moves)
      end

      protected

      attr_writer :inverse
    end
end
