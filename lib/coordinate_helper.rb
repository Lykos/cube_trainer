module CubeTrainer

  module CoordinateHelper
    def highest_coordinate
      n - 1
    end
  
    def valid_coordinate?(x)
      x.is_a?(Integer) && 0 <= x && x < n
    end
  
    # The last coordinate that is strictly before the middle
    def last_before_middle
      n / 2 - 1
    end
  
    # Middle coordinate for uneven numbers, the one before for even numbers
    def middle_or_before
      n - n / 2 - 1
    end
    
    # Middle coordinate for uneven numbers, the one after for even numbers
    def middle_or_after
      n / 2
    end
  
    def invert_coordinate(coordinate)
      highest_coordinate - coordinate
    end
  
    # On a nxn grid with integer coordinates between 0 and n - 1, give the 4 points that point (x, y) hits if you rotate by 90 degrees.
    def rotate_coordinate(x, y)
      [y, invert_coordinate(x)]
    end
  
    # On a nxn grid with integer coordinates between 0 and n - 1, give the 4 points that point (x, y) hits if you do a full rotation of the face in clockwise order.
    def coordinate_rotations(x, y)
      rots = []
      current = [x, y]
      4.times do
        rots.push(current)
        current = rotate_coordinate(*current)
      end
      rots
    end
  end

end
