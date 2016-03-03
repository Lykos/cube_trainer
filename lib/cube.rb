# The order determines the priority of the faces.
COLORS = [:yellow, :red, :green, :blue, :orange, :white]
OPPOSITE_PAIRS = [[:yellow, :white], [:red, :orange], [:green, :blue]].collect { |e| e.sort }.sort

# We need to define one corner to determine the chirality. The other colors follow from this one.
# This is in clockwise order.
CHIRALITY_CORNER = [:yellow, :green, :red]

def generate_parts(clazz)
  COLORS.permutation(clazz::FACES).collect { |p| clazz.new(p) }.select { |p| p.valid? }.sort_by { |p| p.priorities }
end

class Part
  def initialize(colors)
    clazz = self.class
    raise "Colors contain invalid item: #{colors.inspect}" if colors.any? { |c| c.class != Symbol }
    raise "Invalid number of colors #{colors.length} for #{clazz}. Must be #{clazz::FACES}. Got colors: #{colors.inspect}" if colors.length != clazz::FACES
    @colors = colors
  end

  def encode_with(coder)
    coder['colors'] = @colors
  end

  attr_reader :colors

  def priorities
    @colors.collect { |c| COLORS.index(c) }
  end

  def inspect
    self.class.to_s + "(" + @colors.collect { |c| c.to_s }.join(", ") + ")"
  end
end

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
    if CHIRALITY_CORNER.include?(color)
      self
    else
      opposite
    end
  end
end

class Edge < Part
  FACES = 2

  def valid?
    !OPPOSITE_PAIRS.include?(@colors.sort)
  end

  def letter
    ALPHABET[EDGES.index(self)]
  end
end

class Corner < Part
  FACES = 3

  def valid?
    adjacent_edges.all? { |e| e.valid? } && valid_chirality?
  end

  def adjacent_edges
    @adjacent_edges ||= @colors.combination(2).collect { |e| Edge.new(e) }
  end

  def adjacent_faces
    @adjacent_faces ||= @colors.combination(1).collect { |f| Face.new(f) }
  end

  # Rotate a corner such that the given color is the first color.
  def rotate_color_up(c)
    index = @colors.index(c)
    raise "Corner #{self} doesn't have color #{c}." unless index
    rotate_by(@colors.length - index)
  end

  def rotate_by(n)
    Corner.new(@colors.rotate(n))
  end

  def valid_chirality?
    # To make it comparable to our CHIRALITY_CORNER, we switch each face used in c
    # different from the ones used in the CHIRALITY_CORNER for the opposite face.
    canonical_colors = adjacent_faces.collect { |f| f.chirality_canonicalize.color }
    canonical_corner = Corner.new(canonical_colors)
    # Each time we swap a face for the opposite, the chirality direction should be inverted.
    no_swapped_faces = canonical_colors.zip(@colors).count { |a, b| a != b }
    inverted = no_swapped_faces % 2 == 0
    # Rotate the same color up as the upside of the CHIRALITY_CORNER to make it comparable
    rotated_corner = canonical_corner.rotate_color_up(CHIRALITY_CORNER[0])
    # If the corner is not equal to CHIRALITY_CORNER after these transformations,
    # the original corner had a bad chirality.
    rotated_corner.colors != CHIRALITY_CORNER
  end

  def letter
    ALPHABET[CORNERS.index(self)]
  end
end

FACES = generate_parts(Face)
EDGES = generate_parts(Edge)
CORNERS = generate_parts(Corner)
ALPHABET = "a".upto("z").to_a
CUBIES = CORNERS + EDGES

def random_cubie
  CUBIES.sample
end
