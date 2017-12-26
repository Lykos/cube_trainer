require 'cube'

class CubeState
  def initialize(n, stickers)
    raise "Cubes of size smaller than 2 are not supported." if n < 2
    raise "Cubes of size bigger than 5 are not supported." if n > 5
    raise "Cubes must have 6 sides." unless stickers.length == 6
    raise "All sides of a #{n}x#{n} must be #{n}x#{n}." unless stickers.all? { |p| p.length == n && p.all? { |q| q.length == n } }
    raise "All stickers on the cube must have a valid color." unless stickers.all? { |p| p.all? { |q| q.all? { |c| COLORS.include?(c) } } }
    @n = n
    @stickers = stickers
  end

  def self.solved(n)
    stickers = COLORS.collect do |c|
      (0..n).collect { [c] * n }
    end
    CubeState.new(n, stickers)
  end

  # Priority of the closeness to this face.
  # This is used to index the stickers on other faces.
  def face_priority(i)
    [i, 6 - i].min
  end

  # Whether closeness to this face results in smaller indices for the stickers of other faces.
  def close_to_smaller_indices?(i)
    i < 3
  end

  def neighbor_faces(i)
    (0..6).select { |j| face_priority(j) != face_priority(i)  }
  end

  # Returns (in any order) the stickers that belong to the same piece as the given sticker (including that sticker).
  def piece_colors(i, x, y)
    colors = [self[i, x, y]]
    neighbor_faces(i).each do |neighbor_face|
      if jump_coordinate == 0 && close_to_smaller_indices?(neighbor_face) ||
           jump_coordinate == @n - 1 && !close_to_smaller_indices?(neighbor_face)
          
        end
      end
    end
  end

  def find_piece(piece)
    @stickers.each_with_index do |face, i|
      piece.face_indices(@n) do |x, y|
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

  def [](a, b, c, d)
    raise "All stickers on the cube must have a valid color." unless COLORS.include?(d)
    @stickers[a][b][c] = d
  end

  def apply_index_cycle(cycle)
    last_piece = [*cycle[-1]]
    (cycle.length - 1).downto(1) do |i|
      self[*cycle[i]] = self[*cycle[i - 1]]
    end
    self[*cycle[0]] = last_piece
  end

  def apply_move(move)
    raise
  end
end
