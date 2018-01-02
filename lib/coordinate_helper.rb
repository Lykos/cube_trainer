module CoordinateHelper
  # On a nxn grid with integer coordinates between 0 and n - 1, give the 4 points that point (x, y) hits if you rotate by 90 degrees.
  def rotate_coordinate(x, y, n)
    [y, n - 1 - x]
  end
  
  # On a nxn grid with integer coordinates between 0 and n - 1, give the 4 points that point (x, y) hits if you do a full rotation of the face in clockwise order.
  def coordinate_rotations(x, y, n)
    rots = []
    current = [x, y]
    4.times do
      rots.push(current)
      current = rotate_coordinate(*current, n)
    end
    rots
  end
end
