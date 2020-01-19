require 'cube'
require 'cube_constants'

module CubeTrainer
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
      raise ArgumentError if cube_size % 2 == 0
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
      if x >= 0 then x else cube_size + x end
    end

    ON_SLICE_CACHE = {}
    ON_FACE_CACHE = {}

    # Returns arrays of arrays of 4 stickers that have to be interchanged to turn
    # `face`.
    def self.on_face(face, cube_size)
      ON_FACE_CACHE[[face, cube_size]] ||=
        begin
          cycles = []
          0.upto(middle_or_before(cube_size)) do |x|
            0.upto(last_before_middle(cube_size)) do |y|
              cycles.push(new(face, cube_size, x, y).rotations)
            end
          end
          cycles
        end
    end

    # Returns arrays of arrays of 4 stickers that have to be interchanged to do
    # the slice move defined by `slice_face` and `slice_number`.
    def self.on_slice(slice_face, slice_number, cube_size)
      ON_SLICE_CACHE[[slice_face, slice_number, cube_size]] ||=
        begin
          neighbors = slice_face.neighbors
          coordinate_range(cube_size).collect do |x|
            slice_face.neighbors.collect.with_index do |neighbor, i|
              next_neighbor = neighbors[(i + 1) % 4]
              from_face_distances(neighbor, cube_size, [[slice_face, slice_number], [next_neighbor, x]])
            end
          end
        end
    end

    def self.from_face_distances(face, cube_size, face_distances)
      coordinates = [nil, nil]
      face_distances.each do |neighbor, distance|
        index = face.coordinate_index_close_to(neighbor)
        coordinate = if neighbor.close_to_smaller_indices? then distance else invert_coordinate(distance, cube_size) end
        raise ArgumentError if coordinates[index]
        coordinates[index] = coordinate
      end
      raise ArgumentError if coordinates.any? { |c| c.nil? }
      new(face, cube_size, *coordinates)
    end

    def self.center(face, cube_size)
      m = middle(cube_size)
      new(face, cube_size, m, m)
    end
    
    def initialize(face, cube_size, x, y)
      raise ArgumentError, "Unsuitable face #{face.inspect}." unless face.is_a?(Face)
      raise ArgumentError unless cube_size.is_a?(Integer) && cube_size > 0
      @face = face
      @cube_size = cube_size
      @coordinates = [x, y].map { |c| Coordinate.canonicalize(c, cube_size) }
    end

    attr_reader :face, :cube_size, :coordinates

    def x
      @coordinates[0]
    end

    def y
      @coordinates[1]
    end

    def eql?(other)
      self.class.equal?(other.class) && @face == other.face && @cube_size == other.cube_size && @coordinates == other.coordinates
    end

    alias == eql?

    def hash
      [@face, @cube_size, @coordinates].hash
    end

    def can_jump_to?(to_face)
      raise ArgumentError unless to_face.is_a?(Face)
      jump_coordinate_index = @face.coordinate_index_close_to(to_face)
      jump_coordinate = @coordinates[jump_coordinate_index]
      (jump_coordinate == 0 && to_face.close_to_smaller_indices?) ||
        (jump_coordinate == Coordinate.highest_coordinate(cube_size) && !to_face.close_to_smaller_indices?)
    end

    def jump_to_neighbor(to_face)
      raise ArgumentError unless to_face.is_a?(Face)
      raise ArgumentError unless face.neighbors.include?(to_face)
      raise ArgumentError unless can_jump_to?(to_face)
      new_coordinates = @coordinates.dup
      jump_coordinate_index = @face.coordinate_index_close_to(to_face)
      jump_coordinate = new_coordinates.delete_at(jump_coordinate_index)
      new_coordinate_index = to_face.coordinate_index_close_to(@face)
      new_coordinate = make_coordinate_at_edge_to(@face)
      new_coordinates.insert(new_coordinate_index, new_coordinate)
      Coordinate.new(to_face, @cube_size, *new_coordinates)
    end

    def jump_to_coordinates(new_coordinates)
      Coordinate.new(@face, @cube_size, *new_coordinates)
    end

    def make_coordinate_at_edge_to(face)
      if face.close_to_smaller_indices? then 0 else Coordinate.highest_coordinate(@cube_size) end
    end

    # Returns neighbor faces that are closer to this coordinate than their opposite face.
    def close_neighbor_faces
      @face.neighbors.select do |neighbor|
        coordinate = @coordinates[@face.coordinate_index_close_to(neighbor)]
        if neighbor.close_to_smaller_indices?
          is_before_middle?(coordinate)
        else
          is_after_middle?(coordinate)
        end
      end
    end

    def is_after_middle?(x)
      Coordinate.canonicalize(x, @cube_size) > Coordinate.middle_or_before(@cube_size)
    end

    def is_before_middle?(x)
      Coordinate.canonicalize(x, @cube_size) <= Coordinate.last_before_middle(@cube_size)
    end


    # On a nxn grid with integer coordinates between 0 and n - 1, give the 4 points that point (x, y) hits if you rotate by 90 degrees.
    def rotate
      jump_to_coordinates([y, Coordinate.invert_coordinate(x, @cube_size)])
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
    def initialize(face, coordinate)
      raise ArgumentError, "Unsuitable face #{face.inspect}." unless face.is_a?(Face)
      raise ArgumentError unless coordinate.is_a?(Integer) && 0 <= coordinate && coordinate < SKEWB_STICKERS
      @face = face
      @coordinate = coordinate
    end

    def self.center(face)
      new(face, 0)
    end

    def self.corner_index(face, corner_index)
      new(face, corner_index + 1)
    end

    def self.corners_on_face(face)
      (1...SKEWB_STICKERS).collect { |i| new(face, i) }
    end

    def self.for_corner(corner)
      corner_index(Face.for_face_symbol(corner.face_symbols.first), corner.piece_index % 4)
    end

    def hash
      [@face, @coordinate].hash
    end

    def eql?(other)
      self.class.equal?(other.class) && @face == other.face && @coordinate == other.coordinate
    end

    alias == eql?

    def <=>(other)
      if @face != other.face
        @face <=> other.face
      else
        @coordinate <=> other.coordinate
      end
    end

    include Comparable
    include CubeConstants

    attr_reader :face, :coordinate
  end

end
