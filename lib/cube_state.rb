require 'cube'

class CubeState
  SIDES = COLORS.length
  
  def initialize(n, stickers)
    raise 'Cubes of size smaller than 2 are not supported.' if n < 2
    raise 'Cubes of size bigger than 5 are not supported.' if n > 5
    raise "Cubes must have #{SIDES} sides." unless stickers.length == SIDES
    raise "All sides of a #{n}x#{n} must be #{n}x#{n}." unless stickers.all? { |p| p.length == n && p.all? { |q| q.length == n } }
    raise 'All stickers on the cube must have a valid color.' unless stickers.all? { |p| p.all? { |q| q.all? { |c| COLORS.include?(c) } } }
    @n = n
    @stickers = stickers
  end

  def self.solved(n)
    stickers = COLORS.collect do |c|
      (0...n).collect { [c] * n }
    end
    CubeState.new(n, stickers)
  end

  def face_index(face)
    COLORS.index(face.color)
  end

  def face_by_index(i)
    Face::ELEMENTS.find { |face| face_index(face) == i }
  end

  # Priority of the closeness to this face.
  # This is used to index the stickers on other faces.
  def face_priority(face)
    i = face_index(face)
    [i, SIDES - 1 - i].min
  end

  # Whether closeness to this face results in smaller indices for the stickers of other faces.
  def close_to_smaller_indices?(face)
    face_index(face) < 3
  end

  # Returns the index of the coordinate that is used to determine how close a sticker on `on_face` is to `to_face`.
  def coordinate_indicating_closeness_to(on_face, to_face)
    raise unless on_face.neighbors.include?(to_face)
    on_priority = face_priority(on_face)
    to_priority = face_priority(to_face)
    if on_priority < to_priority then
      to_priority - 1
    else
      to_priority
    end
  end

  # Returns (in any order) the stickers that belong to the same piece as the given sticker (including that sticker).
  def piece_colors(i, x, y)
    colors = [self[i, x, y]]
    coordinates = [x, y]
    # Try to jump to each neighbor face across each coordinate.
    face = face_by_index(i)
    face.neighbors.each do |neighbor_face|
      jump_coordinate_index = coordinate_indicating_closeness_to(face, neighbor_face)
      jump_coordinate = coordinates[jump_coordinate_index]
      # Check whether we are actually at the boundary to the neighbor_face
      unless jump_coordinate == 0 && close_to_smaller_indices?(neighbor_face) ||
             jump_coordinate == @n - 1 && !close_to_smaller_indices?(neighbor_face)
        next
      end
      other_coordinates = coordinates.dup
      other_coordinates.delete_at(jump_coordinate_index)
      new_coordinate = if close_to_smaller_indices?(face) then 0 else @n - 1 end
      new_coordinate_index = coordinate_indicating_closeness_to(neighbor_face, face)
      other_coordinates.insert(new_coordinate_index, new_coordinate)
      colors.push(self[face_index(neighbor_face), *other_coordinates])
    end
    colors
  end

  def find_piece(piece)
    @stickers.each_with_index do |face, i|
      piece.face_indices(@n).each do |x, y|
        if piece_colors(i, x, y).sort == piece.colors.sort
          return [i, x, y]
        end
      end
    end
    raise "Couldn't find #{piece}."
  end

  def find_cycles(pieces)
    cycles = []
    pieces[0].rotations.length.times do |i|
      cycles.push([])
      pieces.each do |p|
        cycles.last.push(find_piece(p.rotate_by(i)))
      end
    end
    cycles
  end

  def apply_piece_cycle(pieces)
    raise "Cycles of length smaller than 2 are not supported." if pieces.length < 2
    raise "Cycles of heterogenous piece types are not supported." if pieces.any? { |p| p.class != pieces[0].class }
    raise "Cycles of weird piece types are not supported." unless pieces.all? { |p| p.is_a?(Part) }
    raise "Cycles of invalid pieces are not supported." unless pieces.all? { |p| p.valid? }
    raise "Cycles of invalid pieces are not supported." unless pieces.all? { |p| p.valid_for_cube_size?(@n) }
    pieces.each_with_index do |p, i|
      pieces.each_with_index do |q, j|
        if i != j && p.turned_equals?(q)
          raise "Pieces #{p} and #{q} are equal modulo rotation, so they can't be cycled."
        end
      end
    end
    cycles = find_cycles(pieces)
    cycles.each { |c| apply_index_cycle(c) }
  end

  def [](a, b, c)
    @stickers[a][b][c]
  end

  def []=(a, b, c, d)
    raise "All stickers on the cube must have a valid color." unless COLORS.include?(d)
    @stickers[a][b][c] = d
  end

  def apply_index_cycle(cycle)
    last_piece = self[*cycle[-1]]
    (cycle.length - 1).downto(1) do |i|
      self[*cycle[i]] = self[*cycle[i - 1]]
    end
    self[*cycle[0]] = last_piece
  end

  def rotate_slice(face, slice, direction)
    neighbors = face.neighbors
    y = if close_to_smaller_indices?(face) then slice else @n - slice end
    0.upto(@n - 1) do |x|
      cycle = neighbors.collect.with_index do |neighbor, i|
        previous_neighbor = (i + 1) % 4
        real_x = if close_to_smaller_indices?(previous_neighbor) then x else -x end
        coordinates = [real_x]
        coordinates.insert(coordinate_indicating_closeness_to(neighbor, face), y)
        [face_index] + coordinates
      end
      if direction == 2
        apply_index_cycle(cycle[0], cycle[2])
        apply_index_cycle(cycle[1], cycle[3])
      else
        cycle.reverse! if direction == -1
        apply_index_cycle(cycle)
      end
    end
  end

  # Rotates the stickers on one face (not a real move, only stickers on one face!)
  def rotate_face(face, direction)
    neighbors = face.neighbors
    inverse_order_face = coordinate_indicating_closeness_to(face, neighbors[0]) > coordinate_indicating_closeness_to(face, neighbors[1])
    reverse = (direction == -1) != inverse_order_face
    0.upto(@n - @n/2) do |x|
      0.upto(@n - @n/2) do |y|
        if direction == 2
          apply_index_cycle([[i, @n - 1 - x, y], [i, x, @n - 1 - y]])
          apply_index_cycle([[i, x, y], [i, @n - 1 - x, @n - 1 - y]])
        else
          cycle = [[i, x, y], [i, @n - 1 - x, y], [i, @n - 1 - x, @n - 1 - y], [i, x, @n - 1 - y]]
          cycle.reverse! if reverse
          apply_index_cycle(cycle)
        end
      end
    end
  end

  def apply_move(move)
    move.apply_to(self)
  end
end
