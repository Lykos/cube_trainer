require 'cube'

module CubeTrainer
  # Coordinate of a sticker on the cube
  class Coordinate
    def canonicalize_coordinate(x)
      raise ArgumentErorr unless x.is_a?(Integer) && -@cube_size <= x && x < @cube_size
      if x >= 0 then 0 else @cube_size + x end
    end

    def initialize(face, cube_size, x, y)
      raise ArgumentError unless face.is_a?(Face)
      raise ArgumentError unless cube_size.is_a?(Integer) && cube_size > 0
      @face = face
      @cube_size = cube_size
      @x = canonicalize_coordinate(x)
      @y = canonicalize_coordinate(y)
    end

    attr_reader :face, :cube_size, :x, :y
  end

  def eql?(other)
    self.class.equal?(other.class) && @face == other.face && @cube_size == other.cube_size && @x == other.x && @y == other.y
  end
  
  alias == eql?

  def hash
    [@face, @cube_size, @x, @y].hash
  end

end
