# frozen_string_literal: true

require 'twisty_puzzles/abstract_move'
require 'twisty_puzzles/cube'
require 'twisty_puzzles/coordinate'

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

def move_metric
  choose(*AbstractMove::MOVE_METRICS)
end

def rotation
  Rotation.new(face, non_zero_cube_direction)
end

def simple_move
  FatMove.new(face, non_zero_cube_direction)
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

def slice_index(cube_size)
  range(1, cube_size - 2)
end

def slice_move(cube_size)
  raise ArgumentError if cube_size <= 3

  SliceMove.new(face, non_zero_cube_direction, slice_index(cube_size))
end

def maybe_fat_maybe_slice_move
  MaybeFatMaybeSliceMove.new(face, non_zero_cube_direction)
end

def cube_move(cube_size)
  args = [[10, :simple_move], [1, :rotation]]
  return freq(*args) if cube_size <= 2

  args += [
    [1, :maybe_fat_mslice_maybe_inner_mslice_move],
    [1, :fat_move, cube_size],
    [1, :maybe_fat_maybe_slice_move]
  ]
  return freq(*args) if cube_size <= 3

  args.push([1, :slice_move, cube_size])
  freq(*args)
end

def cube_algorithm(cube_size)
  Algorithm.new(Array.new(size) { cube_move(cube_size) })
end

def rotations
  Algorithm.new(Array.new(size) { rotation })
end

def skewb_corner_move
  SkewbMove.new(corner, non_zero_skewb_direction)
end

def skewb_move
  freq([10, :skewb_corner_move], [1, :rotation])
end

def skewb_algorithm
  Algorithm.new(Array.new(size) { skewb_move })
end

def cube_coordinate(cube_size)
  Coordinate.from_indices(
    face,
    cube_size,
    range(0, cube_size - 1),
    range(0, cube_size - 1)
  )
end

def skewb_corner_coordinate
  SkewbCoordinate.for_corner(corner)
end

def skewb_center_coordinate
  SkewbCoordinate.for_center(face)
end

def skewb_coordinate
  freq([4, :skewb_corner_coordinate], [1, :skewb_center_coordinate])
end
