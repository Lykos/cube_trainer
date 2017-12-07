# The order determines the priority of the faces.
COLORS = [:yellow, :red, :green, :blue, :orange, :white]
OPPOSITE_PAIRS = [[:yellow, :white], [:red, :orange], [:green, :blue]].collect { |e| e.sort }.sort

# We need to define one corner to determine the chirality. The other colors follow from this one.
# This is in clockwise order.
CHIRALITY_COLORS = [:yellow, :green, :red]

def generate_parts(clazz)
  COLORS.permutation(clazz::FACES).collect { |p| clazz.new(p) }.select { |p| p.valid? }.sort_by { |p| p.priorities }
end

class Part
  def initialize(colors)
    clazz = self.class
    raise "Colors contain invalid item: #{colors.inspect}" if colors.any? { |c| c.class != Symbol || !COLORS.include?(c) }
    raise "Invalid number of colors #{colors.length} for #{clazz}. Must be #{clazz::FACES}. Got colors: #{colors.inspect}" if colors.length != clazz::FACES
    @colors = colors
  end

  def encode_with(coder)
    coder['colors'] = @colors
  end

  def eql?(other)
    self.class.equal?(other.class) && @colors == other.colors
  end

  alias == eql?

  def hash
    @colors.hash
  end

  attr_reader :colors

  def priorities
    @colors.collect { |c| COLORS.index(c) }
  end

  def inspect
    self.class.to_s + "(" + @colors.collect { |c| c.to_s }.join(", ") + ")"
  end

  def letter
    @letter ||= ALPHABET[self.class::ELEMENTS.index(self)]
  end

  # Rotate a corner such that the given color is the first color.
  def rotate_color_up(c)
    index = @colors.index(c)
    raise "Corner #{self} doesn't have color #{c}." unless index
    rotate_by(index)
  end

  def rotate_by(n)
    self.class.new(@colors.rotate(n))
  end

  def invert
    self.class.new(@colors.reverse)
  end

  # Returns true if the corners are equal modulo rotation.
  def turned_equals?(other)
    rotate_color_up(other.colors[0]) == other
  end

  def rotations
    (0...@colors.length).collect { |i| rotate_by(i) }
  end
end

# This is an unmoveable center piece, it's mostly used as a helper class for other pieces.
class Face < Part
  FACES = 1

  def opposite
    pair = OPPOSITE_PAIRS.find { |p| p.include?(color) }
    Face.new([pair.find { |f| f != color }])
  end

  def valid?
    true
  end

  def color
    @colors[0]
  end

  # Returns either the face or its opposite face, depending which one is used in CHIRALITY_CORNER.
  def chirality_canonicalize
    if CHIRALITY_COLORS.include?(color)
      self
    else
      opposite
    end
  end

  ELEMENTS = generate_parts(self)
end

class MoveableCenter < Part
  FACES = 1

  def initialize(corresponding_part)
    raise "Invalid corresponding part #{corresponding_part}." unless corresponding_part.is_a?(Part)
    super([corresponding_part.colors[0]])
    @corresponding_part = corresponding_part
  end

  def color
    @colors[0]
  end

  def encode_with(coder)
    coder['corresponding_part'] = @corresponding_part
  end

  def eql?(other)
    self.class.equal?(other.class) && color == other.color && @corresponding_part == other.corresponding_part
  end
  
  alias == eql?

  def hash
    ([color, @index]).hash
  end

  attr_reader :colors, :corresponding_part

  def priorities
    @corresponding_part.priorities
  end

  def inspect
    self.class.to_s + "(" + color.to_s + ", " + @corresponding_part.inspect + ")"
  end
  
  def valid?
    @corresponding_part.valid?
  end

  def self.generate_moveable_centers(clazz)
    clazz::CORRESPONDING_PART_CLASS::ELEMENTS.collect { |p| clazz.new(p) }.sort_by { |p| p.priorities }
  end
end

class Edge < Part
  FACES = 2

  def valid?
    !OPPOSITE_PAIRS.include?(@colors.sort)
  end

  ELEMENTS = generate_parts(self)
  BUFFER = Edge.new([:white, :red])
  raise "Invalid buffer edge." unless BUFFER.valid?
end

class Midge < Part
  FACES = 2

  def valid?
    !OPPOSITE_PAIRS.include?(@colors.sort)
  end

  ELEMENTS = generate_parts(self)
  BUFFER = Midge.new([:white, :red])
  raise "Invalid buffer midge." unless BUFFER.valid?
end

class Wing < Part
  FACES = 2

  def valid?
    true
  end

  ELEMENTS = generate_parts(self)
  BUFFER = Wing.new([:white, :red])
  raise "Invalid buffer wing." unless BUFFER.valid?
end

class Corner < Part
  FACES = 3
  CHIRALITY_CORNER = Corner.new(CHIRALITY_COLORS)

  def valid?
    adjacent_edges.all? { |e| e.valid? } && valid_chirality?
  end

  def adjacent_edges
    @adjacent_edges ||= @colors.combination(2).collect { |e| Edge.new(e) }
  end

  def adjacent_faces
    @adjacent_faces ||= @colors.combination(1).collect { |f| Face.new(f) }
  end

  def valid_chirality?
    # To make it comparable to our CHIRALITY_CORNER, we switch each face used in c
    # different from the ones used in the CHIRALITY_CORNER for the opposite face.
    canonical_colors = adjacent_faces.collect { |f| f.chirality_canonicalize.color }
    canonical_corner = Corner.new(canonical_colors)

    # Each time we swap a face for the opposite, the chirality direction should be inverted.
    no_swapped_faces = canonical_colors.zip(@colors).count { |a, b| a != b }
    inverted = no_swapped_faces % 2 == 1
    inverted_corner = if inverted then canonical_corner.invert else canonical_corner end

    # If the corner is not equal modulo rotation to CHIRALITY_CORNER after this transformation,
    # the original corner had a bad chirality.
    inverted_corner.turned_equals?(CHIRALITY_CORNER)
  end

  ELEMENTS = generate_parts(self)
  BUFFER = Corner.new([:yellow, :blue, :orange])
  raise "Invalid buffer corner." unless BUFFER.valid?
end

class XCenter < MoveableCenter
  CORRESPONDING_PART_CLASS = Corner
  ELEMENTS = generate_moveable_centers(self)
  BUFFER = XCenter.new(Corner.new([:yellow, :blue, :orange]))
  raise "Invalid buffer XCenter." unless BUFFER.valid?
end

class TCenter < MoveableCenter
  CORRESPONDING_PART_CLASS = Edge
  ELEMENTS = generate_moveable_centers(self)
  BUFFER = XCenter.new(Edge.new([:yellow, :orange]))
  raise "Invalid buffer TCenter." unless BUFFER.valid?
end

ALPHABET = "a".upto("x").to_a
CUBIES = Corner::ELEMENTS + Edge::ELEMENTS

def random_cubie
  CUBIES.sample
end
