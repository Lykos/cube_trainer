# frozen_string_literal: true

require 'cube_trainer/core/cube'
require 'cube_trainer/core/cube_constants'
require 'cube_trainer/native'

module CubeTrainer
  module Core
    # Coordinate of a sticker on the cube
    class Coordinate
      def self.highest_coordinate(cube_size)
        cube_size - 1
      end

      def self.invert_coordinate(x, cube_size)
        highest_coordinate(cube_size) - x
      end

      def self.coordinate_range(cube_size)
        0.upto(highest_coordinate(cube_size))
      end

      def self.middle(cube_size)
        raise ArgumentError if cube_size.even?

        cube_size / 2
      end

      # Middle coordinate for uneven numbers, the one before for even numbers
      def self.middle_or_before(cube_size)
        cube_size - cube_size / 2 - 1
      end

      # Middle coordinate for uneven numbers, the one after for even numbers
      def self.middle_or_after(cube_size)
        cube_size / 2
      end

      # The last coordinate that is strictly before the middle
      def self.last_before_middle(cube_size)
        cube_size / 2 - 1
      end

      def self.canonicalize(x, cube_size)
        raise ArgumentError unless x.is_a?(Integer) && -cube_size <= x && x < cube_size

        x >= 0 ? x : cube_size + x
      end

      def self.from_face_distances(face, cube_size, face_distances)
        raise ArgumentError if face_distances.length != 2

        coordinates = [nil, nil]
        face_distances.each do |neighbor, distance|
          index = face.coordinate_index_close_to(neighbor)
          coordinate = neighbor.close_to_smaller_indices? ? distance : invert_coordinate(distance, cube_size)
          raise ArgumentError if coordinates[index]

          coordinates[index] = coordinate
        end
        raise ArgumentError if coordinates.any?(&:nil?)

        from_indices(face, cube_size, *coordinates)
      end

      def self.match_coordinate_internal(_part, base_coordinate, other_face_symbols)
        other_face_symbols.sort!
        coordinate = base_coordinate.rotations.find do |coordinate|
          face_symbols_closeby = coordinate.close_neighbor_faces.map(&:face_symbol)
          face_symbols_closeby.sort == other_face_symbols
        end
        raise "Couldn't find a fitting coordinate on the solved face." if coordinate.nil?

        coordinate
      end

      # The coordinate of the solved position of the main sticker of this part.
      def self.solved_position(part, cube_size, incarnation_index)
        raise TypeError unless part.is_a?(Part)
        raise unless part.class::ELEMENTS.length == 24
        raise unless incarnation_index >= 0 && incarnation_index < part.num_incarnations(cube_size)

        # This is a coordinate on the same face and belonging to an equivalent part. But it might not be the right one.
        base_coordinate = Coordinate.from_indices(part.solved_face, cube_size, *part.base_index_on_face(cube_size, incarnation_index))
        base_coordinate.coordinates; base_coordinate.cube_size
        other_face_symbols = part.corresponding_part.face_symbols[1..-1]
        match_coordinate_internal(part, base_coordinate, other_face_symbols)
      end

      # The coordinate of the solved position of all stickers of this part.
      def self.solved_positions(part, cube_size, incarnation_index)
        solved_coordinate = solved_position(part, cube_size, incarnation_index)
        other_coordinates = part.face_symbols[1..-1].map.with_index do |f, i|
          face = Face.for_face_symbol(f)
          # The reverse is important for edge like parts. We are not in the same position as usual solved pieces would be.
          # For other types of pieces, it doesn't make a difference as the base index will just be a rotation of the original one, but we will anyway look at all rotations later.
          base_indices = part.base_index_on_other_face(face, cube_size, incarnation_index).reverse
          base_coordinate = Coordinate.from_indices(face, cube_size, *base_indices)
          base_coordinate.coordinates; base_coordinate.cube_size
          other_face_symbols = [part.face_symbols[0]] + part.corresponding_part.face_symbols[1...i + 1] + part.corresponding_part.face_symbols[i + 2..-1]
          match_coordinate_internal(part, base_coordinate, other_face_symbols)
        end
        [solved_coordinate] + other_coordinates
      end

      def self.center(face, cube_size)
        m = middle(cube_size)
        from_indices(face, cube_size, m, m)
      end

      def self.edges_outside(face, cube_size)
        face.neighbors.zip(face.neighbors.rotate(1)).collect_concat do |neighbor, next_neighbor|
          1.upto(cube_size - 2).map do |i|
            from_face_distances(neighbor, cube_size, face => 0, next_neighbor => i)
          end
        end
      end

      def self.from_indices(face, cube_size, x, y)
        raise TypeError, "Unsuitable face #{face.inspect}." unless face.is_a?(Face)
        raise TypeError unless cube_size.is_a?(Integer)
        raise ArgumentError unless cube_size > 0

        x = Coordinate.canonicalize(x, cube_size)
        y = Coordinate.canonicalize(y, cube_size)
        native = Native::CubeCoordinate.new(
          cube_size,
          face.face_symbol,
          face.coordinate_index_base_face(0).face_symbol,
          face.coordinate_index_base_face(1).face_symbol,
          x,
          y
        )
        new(native)
      end

      private_class_method :new

      def initialize(native)
        raise TypeError unless native.is_a?(Native::CubeCoordinate)

        @native = native
      end

      attr_reader :native

      def face
        @face ||= Face.for_face_symbol(@native.face)
      end

      def cube_size
        @cube_size ||= @native.cube_size
      end

      def coordinate(coordinate_index)
        native.coordinate(face.coordinate_index_base_face(coordinate_index).face_symbol)
      end

      def coordinates
        @coordinates ||= [x, y]
      end

      def x
        @x ||= coordinate(0)
      end

      def y
        @y ||= coordinate(1)
      end

      def eql?(other)
        self.class.equal?(other.class) && @native == other.native
      end

      alias == eql?

      def hash
        [self.class, @native].hash
      end

      def can_jump_to?(to_face)
        raise ArgumentError unless to_face.is_a?(Face)

        jump_coordinate_index = face.coordinate_index_close_to(to_face)
        jump_coordinate = coordinates[jump_coordinate_index]
        (jump_coordinate == 0 && to_face.close_to_smaller_indices?) ||
          (jump_coordinate == Coordinate.highest_coordinate(cube_size) && !to_face.close_to_smaller_indices?)
      end

      def jump_to_neighbor(to_face)
        raise ArgumentError unless to_face.is_a?(Face)
        raise ArgumentError unless face.neighbors.include?(to_face)
        raise ArgumentError unless can_jump_to?(to_face)

        new_coordinates = coordinates.dup
        jump_coordinate_index = face.coordinate_index_close_to(to_face)
        jump_coordinate = new_coordinates.delete_at(jump_coordinate_index)
        new_coordinate_index = to_face.coordinate_index_close_to(face)
        new_coordinate = make_coordinate_at_edge_to(face)
        new_coordinates.insert(new_coordinate_index, new_coordinate)
        Coordinate.from_indices(to_face, cube_size, *new_coordinates)
      end

      def jump_to_coordinates(new_coordinates)
        Coordinate.from_indices(@face, @cube_size, *new_coordinates)
      end

      def make_coordinate_at_edge_to(face)
        face.close_to_smaller_indices? ? 0 : Coordinate.highest_coordinate(cube_size)
      end

      # Returns neighbor faces that are closer to this coordinate than their opposite face.
      def close_neighbor_faces
        face.neighbors.select do |neighbor|
          coordinate = coordinates[face.coordinate_index_close_to(neighbor)]
          if neighbor.close_to_smaller_indices?
            is_before_middle?(coordinate)
          else
            is_after_middle?(coordinate)
          end
        end
      end

      def is_after_middle?(x)
        Coordinate.canonicalize(x, cube_size) > Coordinate.middle_or_before(cube_size)
      end

      def is_before_middle?(x)
        Coordinate.canonicalize(x, cube_size) <= Coordinate.last_before_middle(cube_size)
      end

      # On a nxn grid with integer coordinates between 0 and n - 1, iterates between the 4 points that point (x, y) hits if you rotate by 90 degrees.
      def rotate
        jump_to_coordinates([y, Coordinate.invert_coordinate(x, cube_size)])
      end

      # On a nxn grid with integer coordinates between 0 and n - 1, give the 4 points that point (x, y) hits if you do a full rotation of the face in clockwise order.
      def rotations
        rots = []
        current = self
        4.times do
          rots.push(current)
          current = current.rotate
        end
        raise unless current == self

        rots
      end
    end

    class SkewbCoordinate
      def initialize(face, coordinate, native)
        raise ArgumentError, "Unsuitable face #{face.inspect}." unless face.is_a?(Face)
        unless coordinate.is_a?(Integer) && coordinate >= 0 && coordinate < SKEWB_STICKERS
          raise ArgumentError
      end

        @coordinate = coordinate
        @native = native
      end

      attr_reader :native

      private_class_method :new

      def self.for_center(face)
        native = Native::SkewbCoordinate.for_center(face.face_symbol)
        new(face, 0, native)
      end

      def self.corners_on_face(face)
        face.clockwise_corners.collect { |c| for_corner(c) }
      end

      def self.for_corner(corner)
        native = Native::SkewbCoordinate.for_corner(corner.face_symbols)
        new(Face.for_face_symbol(corner.face_symbols.first), 1 + corner.piece_index % 4, native)
      end

      def hash
        @hash ||= [self.class, @native].hash
      end

      def eql?(other)
        @native.eql?(other.native)
      end

      alias == eql?

      def <=>(other)
        @native <=> other.native
      end

      def face
        @face ||= Face.for_face_symbol(@native.face)
      end

      include Comparable
      include CubeConstants

      attr_reader :coordinate
    end
  end
end
