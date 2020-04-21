# frozen_string_literal: true

require 'twisty_puzzles/cancellation_helper'
require 'twisty_puzzles/cube'
require 'twisty_puzzles/cube_direction'
require 'twisty_puzzles/skewb_direction'
require 'twisty_puzzles/skewb_move'

module TwistyPuzzles
  
    # Class that represents one notation for Skewb moves, e.g. Sarahs notation or fixed
    # corner notation.
    class SkewbNotation
      def initialize(name, move_corner_pairs)
        raise TypeError unless name.is_a?(String)

        check_move_corner_pairs(move_corner_pairs)
        @name = name
        @move_to_corner = move_corner_pairs.to_h.freeze
        @corner_to_move = move_corner_pairs.collect_concat do |m, c|
          c.rotations.map { |e| [e, m] }
        end.to_h.freeze
        @move_strings = move_corner_pairs.map(&:first).freeze
        @non_zero_moves =
          move_corner_pairs.map(&:last).product(SkewbDirection::NON_ZERO_DIRECTIONS).map do |c, d|
            SkewbMove.new(c, d)
          end.freeze
        freeze
      end

      def check_move_corner_pairs(move_corner_pairs)
        move_corner_pairs.each do |m|
          raise ArgumentError unless m.length == 2
          raise TypeError unless m[0].is_a?(String)
          raise TypeError unless m[1].is_a?(Corner)
        end
        if move_corner_pairs.map(&:first).uniq.length != move_corner_pairs.length
          raise ArgumentError
        end

        check_corner_coverage(move_corner_pairs.map(&:last))
      end

      def check_corner_coverage(corners)
        corner_closure = corners + corners.map(&:diagonal_opposite)
        Corner::ELEMENTS.each do |corner|
          unless corner_closure.any? { |c| c.turned_equals?(corner) }
            raise ArgumentError,
                  "Turns around corner #{corner} cannot be represented in notation #{name}."
          end
        end
      end

      attr_reader :name, :move_strings, :non_zero_moves
      private_class_method :new

      def self.fixed_corner
        @fixed_corner ||= new(
          'fixed corner', [
            ['U', Corner.for_face_symbols(%i[U L B])],
            ['R', Corner.for_face_symbols(%i[D R B])],
            ['L', Corner.for_face_symbols(%i[D F L])],
            ['B', Corner.for_face_symbols(%i[D B L])]
          ]
        )
      end

      def self.sarah
        @sarah ||= new(
          'sarah', [
            ['F', Corner.for_face_symbols(%i[U R F])],
            ['R', Corner.for_face_symbols(%i[U B R])],
            ['B', Corner.for_face_symbols(%i[U L B])],
            ['L', Corner.for_face_symbols(%i[U F L])]
          ]
        )
      end

      def self.rubiks
        @rubiks ||= new(
          'rubiks', [
            ['F', Corner.for_face_symbols(%i[U R F])],
            ['R', Corner.for_face_symbols(%i[U B R])],
            ['B', Corner.for_face_symbols(%i[U L B])],
            ['L', Corner.for_face_symbols(%i[U F L])],
            ['f', Corner.for_face_symbols(%i[D F R])],
            ['r', Corner.for_face_symbols(%i[D R B])],
            ['b', Corner.for_face_symbols(%i[D B L])],
            ['l', Corner.for_face_symbols(%i[D L F])]
          ]
        )
      end

      def to_s
        @name
      end

      def corner(move)
        @move_to_corner[move] || (raise ArgumentError)
      end

      def algorithm_to_string(algorithm)
        reversed_rotations = []
        num_tail_rotations = CancellationHelper.num_tail_rotations(algorithm)
        alg_string = algorithm.moves[0...algorithm.length - num_tail_rotations].map do |m|
          move_to_string(m, reversed_rotations)
        end.join(' ')
        new_tail_rotations = reversed_rotations.reverse! +
                             algorithm.moves[algorithm.length - num_tail_rotations..-1]
        cancelled_rotations = Algorithm.new(new_tail_rotations).cancelled(3)
        cancelled_rotations.empty? ? alg_string : "#{alg_string} #{cancelled_rotations}"
      end

      private

      def move_to_string(move, reversed_rotations)
        reversed_rotations.each { |r| move = move.rotate_by(r.inverse) }
        case move
        when SkewbMove then skewb_move_to_string(move, reversed_rotations)
        when Rotation then move.to_s
        else raise ArgumentError, "Couldn't transform #{move} to #{@name} Skewb notation."
        end
      end

      def skewb_move_to_string(move, reversed_rotations)
        move_string, rotate = move_to_string_internal(move)
        if rotate
          reversed_additional_rotations =
            Rotation.around_corner(move.axis_corner, move.direction).moves.reverse
          reversed_rotations.concat(reversed_additional_rotations)
        end
        "#{move_string}#{move.direction.name}"
      end

      # Returns the move string of the given move and true if a rotation has to be done to correct
      # for the fact that we actually used the opposite corner.
      def move_to_string_internal(move)
        if (move_string = @corner_to_move[move.axis_corner])
          [move_string, false]
        elsif (move_string = @corner_to_move[move.axis_corner.diagonal_opposite])
          [move_string, !move.direction.zero?]
        else
          raise
        end
      end
    end
end
