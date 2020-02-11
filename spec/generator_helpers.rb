require 'cube_trainer/core/cube'
require 'cube_trainer/core/coordinate'

def face
  choose(*Face::ELEMENTS)
end

def corner
  choose(*Corner::ELEMENTS)
end

def non_zero_cube_direction
  choose(*CubeDirection::NON_ZERO_DIRECTIONS)
end

def non_zero_skewb_direction
  choose(*SkewbDirection::NON_ZERO_DIRECTIONS)
end

def rotation
  Rotation.new(face, non_zero_cube_direction)
end

def simple_move
  FatMove.new(face, non_zero_cube_direction, 1)
end

def maybe_fat_mslice_maybe_inner_mslice_move
  MaybeFatMSliceMaybeInnerMSliceMove.new(face, non_zero_cube_direction)
end

def width(cube_size)
  range(1, cube_size - 1)
end

def fat_move(cube_size)
  FatMove.new(face, non_zero_cube_direction, width(cube_size))
end

def maybe_fat_maybe_slice_move
  MaybeFatMaybeSliceMove.new(face, non_zero_cube_direction)
end

def cube_move(cube_size)
  return freq [10, :simple_move], [1, :rotation] if cube_size <= 2
  freq [10, :simple_move], [1, :rotation], [1, :maybe_fat_mslice_maybe_inner_mslice_move], [1, :fat_move, cube_size], [1, :maybe_fat_maybe_slice_move]
end

def cube_algorithm(cube_size)
  Algorithm.new(size.times.map { cube_move(cube_size) })
end

def skewb_corner_move
  SkewbMove.new(corner, non_zero_skewb_direction)
end

def skewb_move
  freq [10, :skewb_corner_move], [1, :rotation]
end

def skewb_algorithm
  Algorithm.new(size.times.map { skewb_move })
end

def cube_coordinate(cube_size)
  Coordinate.from_indices(face, cube_size, range(0, cube_size - 1), range(0, cube_size - 1))
end

def skewb_corner_coordinate
  SkewbCoordinate.for_corner(corner)
end

def skewb_center_coordinate
  SkewbCoordinate.for_center(face)
end

def skewb_coordinate
  freq [4, :skewb_corner_coordinate], [1, :skewb_center_coordinate]
end
