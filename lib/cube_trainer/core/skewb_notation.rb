require 'cube_trainer/core/cancellation_helper'
require 'cube_trainer/core/cube'
require 'cube_trainer/core/cube_direction'
require 'cube_trainer/core/skewb_direction'
require 'cube_trainer/core/skewb_move'

module CubeTrainer
  module Core
    # Class that represents one notation for Skewb moves, e.g. Sarahs notation or fixed
    # corner notation.
    class SkewbNotation
      def initialize(name, move_corner_pairs)
        raise TypeError unless name.is_a?(String)
        move_corner_pairs.each do |m|
          raise ArgumentError unless m.length == 2
          raise TypeError unless m[0].is_a?(String)
          raise TypeError unless m[1].is_a?(Corner)
        end
        if move_corner_pairs.map(&:first).uniq.length != move_corner_pairs.length
          raise ArgumentError
        end

        Corner::ELEMENTS.each do |c|
          unless move_corner_pairs.any? { |p| c.turned_equals?(p[1]) || c.diagonal_opposite.turned_equals?(p[1]) }
            raise ArgumentError, "Turns around corner #{c} cannot be represented in notation #{name}."
          end
        end
        @name = name
        @move_to_corner = move_corner_pairs.to_h.freeze
        @corner_to_move = move_corner_pairs.collect_concat do |m, c|
          c.rotations.map { |e| [e, m] }
        end.to_h.freeze
        @move_strings = move_corner_pairs.map(&:first).freeze
        @all_moves = move_corner_pairs.map(&:last).product(SkewbDirection::NON_ZERO_DIRECTIONS).map do |c, d|
          SkewbMove.new(c, d)
        end.freeze
        freeze
      end

      attr_reader :name, :move_strings, :all_moves
      private_class_method :new

      FIXED_CORNER = new('fixed corner', [
                           ['U', Corner.for_face_symbols(%i[U L B])],
                           ['R', Corner.for_face_symbols(%i[D R B])],
                           ['L', Corner.for_face_symbols(%i[D F L])],
                           ['B', Corner.for_face_symbols(%i[D B L])]                           
                         ])
      SARAH = new('sarah', [
                    ['F', Corner.for_face_symbols(%i[U R F])],
                    ['R', Corner.for_face_symbols(%i[U B R])],
                    ['B', Corner.for_face_symbols(%i[U L B])],
                    ['L', Corner.for_face_symbols(%i[U F L])]
                  ])
      RUBIKS = new('rubiks', [
                     ['F', Corner.for_face_symbols(%i[U R F])],
                     ['R', Corner.for_face_symbols(%i[U B R])],
                     ['B', Corner.for_face_symbols(%i[U L B])],
                     ['L', Corner.for_face_symbols(%i[U F L])]
                     ['f', Corner.for_face_symbols(%i[D F R])],
                     ['r', Corner.for_face_symbols(%i[D R B])],
                     ['b', Corner.for_face_symbols(%i[D B L])],
                     ['l', Corner.for_face_symbols(%i[D L F])]
                   ])

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
          reversed_rotations.each { |r| m = m.rotate_by(r.inverse) }
          case m
          when SkewbMove
            skewb_move_to_string(m, reversed_rotations)
          when Rotation
            m.to_s
          else
            raise ArgumentError, "Couldn't transform #{m} to #{@name} Skewb notation."
          end
        end.join(' ')
        new_tail_rotations = reversed_rotations.reverse! + algorithm.moves[algorithm.length - num_tail_rotations..-1]
        cancelled_rotations = Algorithm.new(new_tail_rotations).cancelled(3)
        cancelled_rotations.empty? ? alg_string : "#{alg_string} #{cancelled_rotations}"
      end

      private

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
end
