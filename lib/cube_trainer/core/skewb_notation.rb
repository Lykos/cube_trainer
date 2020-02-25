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

      attr_reader :move_strings, :all_moves
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

      def to_s
        @name
      end

      def corner(move)
        @move_to_corner[move] || (raise ArgumentError)
      end

      def move_to_string(move)
        raise unless move.is_a?(SkewbMove)
        skewb_move_to_string(move)
      end

      def algorithm_to_string(algorithm)
        rotations = []
        algorithm.moves.map do |m|
          puts rotations.join(' ')
          puts m
          if m.is_a?(SkewbMove)
            a = skewb_move_to_string(m, rotations)
            puts a
            a
          elsif m.is_a?(Rotation)
            rotation.to_s
          else
            raise ArgumentError, "Couldn't transform #{m} to #{@name} Skewb notation."
          end
        end.join(' ')
      end

      private

      # Translates a Skewb direction into a cube direction.
      def translated_direction(direction)
        case direction
        when SkewbDirection::ZERO then CubeDirection::ZERO
        when SkewbDirection::FORWARD then CubeDirection::FORWARD
        when SkewbDirection::BACKWARD then CubeDirection::BACKWARD
        end
      end

      def skewb_move_to_string(move, rotations = nil)
        rotations.reverse_each { |r| move = move.rotate_by(r) } if rotations
        move_string, rotate = move_to_string_internal(move)
        if rotate && rotations
          direction = translated_direction(move.direction)
          rotations.push(Rotation.new(move.axis_corner.faces[0], direction))
          rotations.push(Rotation.new(move.axis_corner.faces[move.direction.inverse.value], direction))
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
