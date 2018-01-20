module CubeTrainer

  # TODO Create a class coordinate instead.
  module CoordinateHelper
    def n
      raise NotImplementedError, "Either implement function n or pass the size explicitly."
    end
    
    def highest_coordinate(size=n)
      size - 1
    end
  
    def valid_coordinate?(x, size=n)
      x.is_a?(Integer) && -size <= x && x < size
    end

    def coordinate_at_lower_end?(x, size=n)
      raise unless valid_coordinate?(x, size)
      x == 0 || x == -size
    end
  
    def coordinate_at_higher_end?(x, size=n)
      raise unless valid_coordinate?(x, size)
      x == highest_coordinate(size) || x == -1
    end

    def make_positive(x, size=n)
      if x >= 0 then x else size + x end
    end

    def equivalent_coordinates(coordinates_a, coordinates_b, size=n)
      coordinates_a.zip(coordinates_b).all? { |a, b| make_positive(a, size) == make_positive(b, size) }
    end

    def is_after_middle?(x, size=n)
      raise unless valid_coordinate?(x, size)
      make_positive(x, size) > middle_or_before(size)
    end

    def is_before_middle?(x, size=n)
      raise unless valid_coordinate?(x, size)
      make_positive(x, size) <= last_before_middle(size)
    end
  
    # The last coordinate that is strictly before the middle
    def last_before_middle(size=n)
      size / 2 - 1
    end

    def middle(size=n)
      raise ArgumentError if size % 2 == 0
      size / 2
    end
  
    # Middle coordinate for uneven numbers, the one before for even numbers
    def middle_or_before(size=n)
      size - size / 2 - 1
    end
    
    # Middle coordinate for uneven numbers, the one after for even numbers
    def middle_or_after(size=n)
      size / 2
    end
  
    def invert_coordinate(coordinate)
      highest_coordinate - coordinate
    end
  
    # On a nxn grid with integer coordinates between 0 and n - 1, give the 4 points that point (x, y) hits if you rotate by 90 degrees.
    def rotate_coordinate(x, y)
      [y, -1 - x]
    end
  
    # On a nxn grid with integer coordinates between 0 and n - 1, give the 4 points that point (x, y) hits if you do a full rotation of the face in clockwise order.
    def coordinate_rotations(coordinates)
      raise unless coordinates.is_a?(Array) && coordinates.length == 2 && coordinates.all? { |c| c.is_a?(Integer) }
      rots = []
      4.times do
        rots.push(coordinates)
        coordinates = rotate_coordinate(*coordinates)
      end
      rots
    end
  end

end
