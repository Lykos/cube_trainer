require 'cube'
require 'array_helper'
require 'coordinate_helper'
require 'cube_print_helper'

class CubeState
  include ArrayHelper
  include CoordinateHelper
  include CubePrintHelper
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

  attr_reader :n, :stickers

  def encode_with(coder)
    coder['stickers'] = @stickers
    coder['n'] = @n
  end

  def eql?(other)
    self.class.equal?(other.class) && @stickers == other.stickers && @n == other.n
  end

  alias == eql?

  def hash
    [@stickers, @n].hash
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

  # Returns the neighbor faces that are close to the given sticker.
  # A face is considered close to the given sticker if it's closer than its opposite face.
  # The result are continguous neighbors in clockwise order.
  def closest_faces(face, x, y)
    faces = []
    coordinates = [x, y]
    # Try to jump to each neighbor face.
    face.neighbors.each do |neighbor_face|
      jump_coordinate_index = coordinate_indicating_closeness_to(face, neighbor_face)
      jump_coordinate = coordinates[jump_coordinate_index]
      # Check whether we are actually close to the neighbor_face
      if (jump_coordinate < @n / 2 && close_to_smaller_indices?(neighbor_face)) ||
         (jump_coordinate >= @n - @n / 2 && !close_to_smaller_indices?(neighbor_face))
        faces.push(neighbor_face)
      else
        faces.push(nil)
      end
    end
    rotate_out_nils(faces)
  end

  def solved_position(piece)
    face = Face.for_color(piece.colors.first)
    representative_piece = piece.corresponding_part
    raise unless representative_piece.colors.first == face.color
    other_colors = representative_piece.colors[1..-1]
    piece.face_indices(@n).each do |x, y|
      return [face, x, y] if closest_faces(face, x, y).collect { |f| f.color } == other_colors
    end
    raise "Couldn't find piece #{piece.inspect} in the solved position."
  end

  def face_lines(face, reverse_lines, reverse_columns)
    stickers_to_lines(@stickers[face_index(face)], reverse_lines, reverse_columns)
  end

  def to_s
    # TODO Push more functionality into CubePrintHelper in order to not pollute this class
    yellow_face = face_lines(Face.for_color(:yellow), true, true)
    blue_face = face_lines(Face.for_color(:blue), false, true)
    red_face = face_lines(Face.for_color(:red), false, true)
    green_face = face_lines(Face.for_color(:green), false, false)
    orange_face = face_lines(Face.for_color(:orange), false, false)
    white_face = face_lines(Face.for_color(:white), false, true)
    middle_belt = zip_concat_lines(blue_face, red_face, green_face, orange_face)
    lines = pad_lines(yellow_face, @n) + middle_belt + pad_lines(white_face, @n)
    lines.join('\n')
  end

  def find_cycles(pieces)
    cycles = []
    pieces[0].rotations.length.times do |i|
      cycles.push([])
      pieces.each do |p|
        cycles.last.push(solved_position(p.rotate_by(i)))
      end
    end
    cycles
  end

  # Cycles the given positions. Note that it does NOT search for the given pieces and cycle them, rather, it cycles
  # the pieces that are at the position that those pieces would take in a solved state.
  def apply_piece_cycle(pieces)
    raise 'Cycles of length smaller than 2 are not supported.' if pieces.length < 2
    raise 'Cycles of heterogenous piece types are not supported.' if pieces.any? { |p| p.class != pieces[0].class }
    raise 'Cycles of weird piece types are not supported.' unless pieces.all? { |p| p.is_a?(Part) }
    raise 'Cycles of invalid pieces are not supported.' unless pieces.all? { |p| p.valid? }
    raise 'Cycles of invalid pieces are not supported.' unless pieces.all? { |p| p.valid_for_cube_size?(@n) }
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

  def [](face, b, c)
    raise unless face.is_a?(Face)
    raise if b < 0 || b >= @n
    raise if c < 0 || c >= @n
    @stickers[face_index(face)][b][c]
  end

  def []=(face, b, c, d)
    raise unless face.is_a?(Face)
    raise if b < 0 || b >= @n
    raise if c < 0 || c >= @n
    raise "All stickers on the cube must have a valid color." unless COLORS.include?(d)
    @stickers[face_index(face)][b][c] = d
  end

  def apply_index_cycle(cycle)
    last_sticker = self[*cycle[-1]]
    (cycle.length - 1).downto(1) do |i|
      self[*cycle[i]] = self[*cycle[i - 1]]
    end
    self[*cycle[0]] = last_sticker
  end

  def apply_4sticker_cycle(cycle, direction)
    raise unless cycle.length == 4
    if direction == 2
      apply_index_cycle([cycle[0], cycle[2]])
      apply_index_cycle([cycle[1], cycle[3]])
    else
      cycle.reverse! if direction == 3
      apply_index_cycle(cycle)
    end
  end

  def rotate_slice(face, slice, direction)
    neighbors = face.neighbors
    y = if close_to_smaller_indices?(face) then slice else @n - 1 - slice end
    0.upto(@n - 1) do |x|
      cycle = neighbors.collect.with_index do |neighbor, i|
        next_neighbor = neighbors[(i + 1) % 4]
        real_x = if close_to_smaller_indices?(next_neighbor) then x else @n - 1 - x end
        coordinates = [real_x]
        coordinates.insert(coordinate_indicating_closeness_to(neighbor, face), y)
        [neighbor] + coordinates
      end
      apply_4sticker_cycle(cycle, direction)
    end
  end

  # Rotates the stickers on one face (not a real move, only stickers on one face!)
  def rotate_face(face, direction)
    neighbors = face.neighbors
    inverse_order_face = coordinate_indicating_closeness_to(face, neighbors[0]) < coordinate_indicating_closeness_to(face, neighbors[1])
    direction = 4 - direction if inverse_order_face
    0.upto(@n/2 - 1) do |x|
      0.upto(@n - @n/2 - 1) do |y|
        cycle = coordinate_rotations(x, y, @n).collect { |x, y| [face, x, y] }
        apply_4sticker_cycle(cycle, direction)
      end
    end
  end

  def apply_move(move)
    move.apply_to(self)
  end
end
