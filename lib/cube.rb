require 'coordinate'

module CubeTrainer

  # The order determines the priority of the faces.
  COLORS = [:yellow, :red, :green, :blue, :orange, :white]
  SIDES = COLORS.length
  OPPOSITE_PAIRS = [[:yellow, :white], [:red, :orange], [:green, :blue]].collect { |e| e.sort }.sort
  FACE_NAMES = ['U', 'F', 'R', 'L', 'B', 'D']
  ALPHABET_SIZE = 24
  SKEWB_STICKERS = 5
  raise unless COLORS.length == FACE_NAMES.length
  
  # We need to define one corner to determine the chirality. The other colors follow from this one.
  # This is in clockwise order.
  # TODO get rid of this
  CHIRALITY_COLORS = [:yellow, :green, :red]
  
  class Part
    def initialize(colors)
      clazz = self.class
      raise "Colors contain invalid item: #{colors.inspect}" if colors.any? { |c| c.class != Symbol || !COLORS.include?(c) }
      raise "Invalid number of colors #{colors.length} for #{clazz}. Must be #{clazz::FACES}. Got colors: #{colors.inspect}" if colors.length != clazz::FACES
      @colors = colors
    end
  
    def self.generate_parts
      parts = COLORS.permutation(self::FACES).collect { |p| new(p) }.select { |p| p.valid? }.sort_by { |p| p.priorities }
      raise unless parts.length <= ALPHABET_SIZE
      parts
    end
  
    def self.for_colors_internal(colors)
      raise unless colors.length == self::FACES
      self::ELEMENTS.find { |e| e.colors == colors }
    end

    def self.for_colors(colors)
      for_colors_internal(colors)
    end

    def self.for_index(i)
      self::ELEMENTS[i]
    end
  
    def encode_with(coder)
      coder['colors'] = @colors
    end

    def <=>(other)
      @piece_index <=> other.piece_index
    end

    include Comparable
  
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

    def piece_index
      self.class::ELEMENTS.index(self)
    end
  
    # Rotate a piece such that the given color is the first color.
    def rotate_color_up(c)
      index = @colors.index(c)
      raise "Part #{self} doesn't have color #{c}." unless index
      rotate_by(index)
    end
  
    def rotate_by(n)
      self.class.new(@colors.rotate(n))
    end
  
    def invert
      self.class.new(@colors.reverse)
    end
  
    # Returns true if the pieces are equal modulo rotation.
    def turned_equals?(other)
      @colors.include?(other.colors.first) && rotate_color_up(other.colors.first) == other
    end
  
    def rotations
      (0...@colors.length).collect { |i| rotate_by(i) }
    end
  
    def self.create_for_colors(colors)
      self.new(colors)
    end
  
    def self.parse(piece_description)
      colors = piece_description.upcase.strip.split('').collect { |e| COLORS[FACE_NAMES.index(e)] }
      for_colors(colors)
    end
  
    # Only overridden by moveable centers, but returns self for convenience.
    def corresponding_part
      self
    end

    # The primary face that this piece is in in the solved state.
    def solved_face
      @solved_face ||= Face.for_color(@colors.first)
    end

    def solved_coordinates
      @solved_coordinates ||= {}
    end

    # Coordinate in the solved state.
    def solved_coordinate(cube_size, incarnation_index)
      solved_coordinates[[cube_size, incarnation_index]] ||=
        begin
          raise unless self.class::ELEMENTS.length == 24
          raise unless incarnation_index >= 0 && incarnation_index < num_incarnations(cube_size)
          base_coordinate = Coordinate.new(solved_face, cube_size, *base_index_on_face(cube_size, incarnation_index))
          other_colors = corresponding_part.colors[1..-1].sort
          coordinate = base_coordinate.rotations.find do |coordinate|
            colors_closeby = coordinate.close_neighbor_faces.map { |f| f.color }
            colors_closeby.sort == other_colors
          end
          raise "Couldn't find a fitting coordinate on the solved face." if coordinate.nil?
          coordinate
        end
    end
  end
  
  # This is an unmoveable center piece, it's mostly used as a helper class for other pieces.
  class Face < Part
    FACES = 1
  
    def self.for_color(color)
      for_colors([color])
    end
    
    # Whether closeness to this face results in smaller indices for the stickers of other faces.
    def close_to_smaller_indices?
      piece_index < 3
    end
  
    def opposite
      pair = OPPOSITE_PAIRS.find { |p| p.include?(color) }
      Face.new([pair.find { |f| f != color }])
    end

    # Returns the index of the coordinate that is used to determine how close a sticker on `on_face` is to `to_face`.
    def coordinate_index_close_to(to_face)
      raise ArgumentError, "Cannot get the coordinate index close to #{to_face.inspect} on #{inspect} because they are not neighbors." unless neighbors.include?(to_face)
      to_priority = to_face.axis_priority
      if axis_priority < to_priority then
        to_priority - 1
      else
        to_priority
      end
    end
  
    # Priority of the closeness to this face.
    # This is used to index the stickers on other faces.
    def axis_priority
      @axis_priority ||= [piece_index, SIDES - 1 - piece_index].min
    end
  
    def valid?
      true
    end
  
    def name
      @name ||= FACE_NAMES[ELEMENTS.index(self)]
    end
  
    def self.by_name(name)
      ELEMENTS[FACE_NAMES.index(name)]
    end
  
    def color
      @colors[0]
    end
  
    # Neighbor faces in clockwise order.
    def neighbors
      @neighbors ||= begin
                       partial_neighbors = self.class::ELEMENTS.select { |e| e != chirality_canonicalize && e == e.chirality_canonicalize }
                       ordered_partial_neighbors = if Corner.between_faces([self] + partial_neighbors).valid?
                                                     partial_neighbors
                                                   elsif Corner.between_faces([self] + partial_neighbors.reverse).valid?
                                                     partial_neighbors.reverse
                                                   else
                                                     raise "Couldn't find a proper order for the neighbor faces #{partial_neighbors.inspect} of #{inspect}."
                                                   end
                       ordered_partial_neighbors + ordered_partial_neighbors.collect { |e| e.opposite }
                     end
    end
  
    # Returns either the face or its opposite face, depending which one is used in CHIRALITY_CORNER.
    def chirality_canonicalize
      if CHIRALITY_COLORS.include?(color)
        self
      else
        opposite
      end
    end
  
    ELEMENTS = generate_parts
  end
  
  class MoveableCenter < Part
    FACES = 1
  
    def initialize(corresponding_part)
      raise "Invalid corresponding part #{corresponding_part}." unless corresponding_part.is_a?(Part)
      super([corresponding_part.colors[0]])
      @corresponding_part = corresponding_part
    end

    def self.for_colors(colors)
      raise unless colors.length == self::CORRESPONDING_PART_CLASS::FACES
      corresponding_part = self::CORRESPONDING_PART_CLASS.for_colors(colors)
      nil unless corresponding_part
      self::ELEMENTS.find { |e| e.corresponding_part == corresponding_part }
    end
  
    def self.create_for_colors(colors)
      self.new(self::CORRESPONDING_PART_CLASS.create_for_colors(colors))
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
  
    def rotate_by(n)
      self
    end
  
    def invert
      self
    end
    
    def valid?
      @corresponding_part.valid?
    end
  
    def neighbor?(other)
      color == other.color
    end
  
    def neighbors
      self.class::ELEMENTS.select { |p| neighbor?(p) }
    end
  
    def self.generate_parts
      self::CORRESPONDING_PART_CLASS::ELEMENTS.collect { |p| new(p) }.sort_by { |p| p.priorities }
    end
  end
  
  class Edge < Part
    FACES = 2
  
    def valid?
      !OPPOSITE_PAIRS.include?(@colors.sort)
    end
  
    ELEMENTS = generate_parts
  
    def num_incarnations(cube_size)
      if cube_size == 3 then 1 else 0 end
    end

    # One index of such a piece on a on a NxN face.
    def base_index_on_face(cube_size, incarnation_index)
      [0, 1]
    end
  end
  
  class Midge < Part
    FACES = 2
  
    def valid?
      !OPPOSITE_PAIRS.include?(@colors.sort)
    end
  
    ELEMENTS = generate_parts
  
    # One index of such a piece on a on a NxN face.
    def base_index_on_face(cube_size, incarnation_index)
      [0, Coordinate.middle(cube_size)]
    end
  
    def num_incarnations(cube_size)
      if cube_size >= 5 && cube_size % 2 == 1 then 1 else 0 end
    end
  end
  
  class Wing < Part
    FACES = 2
  
    def valid?
      !OPPOSITE_PAIRS.include?(@colors.sort)
    end
  
    def self.for_colors(colors)
      # One additional color is usually  mentioned for wings.
      raise unless colors.length == FACES || colors.length == FACES + 1
      if colors.length == 3
        valid = Corner.new(colors).valid?
        reordered_colors = colors.dup
        reordered_colors[0], reordered_colors[1] = reordered_colors[1], reordered_colors[0]
        reordered_valid = Corner.new(reordered_colors).valid?
        raise "Couldn't determine chirality for #{colors.inspect} which is needed to parse a wing." if valid == reordered_valid
        if valid then for_colors(colors[0..1]) else for_colors_internal(reordered_colors[0..1]) end
      else
        for_colors_internal(colors)
      end
    end
  
    def corresponding_part
      @corresponding_part ||= begin
                                corners = COLORS.collect { |c| Corner.new(@colors + [c]) }.select { |c| c.valid? }
                                raise "Couldn't determine corresponding corner for #{inspect}." if corners.length != 1
                                corners.first
                              end
    end
  
    def rotations
      [self]
    end
  
    def rotate_by(n)
      self
    end

    def num_incarnations(cube_size)
      [cube_size / 2 - 1, 0].max
    end
  
    ELEMENTS = generate_parts
  
    # One index of such a piece on a on a NxN face.
    def base_index_on_face(cube_size, incarnation_index)
      invert = solved_face.piece_index % 2 == 0
      coordinates = [0, 1 + incarnation_index]
      if invert then coordinates.reverse else coordinates end
    end
  end
  
  class Corner < Part
    FACES = 3
    CHIRALITY_CORNER = Corner.new(CHIRALITY_COLORS)
  
    def self.create_for_colors(colors)
      piece_candidates = colors[1..-1].permutation.collect { |cs| new([colors[0]] + cs) }
      pieces = piece_candidates.select { |p| p.valid? }
      raise "#{piece_description} is not unique to create a #{self}: #{pieces.inspect}" unless pieces.length == 1
      pieces.first
    end

    def self.for_colors(colors)
      raise "Invalid number of colors to create a corner: #{colors.inspect}" unless colors.length == FACES
      for_colors_internal(colors) || for_colors_internal([colors[0], colors[2], colors[1]])
    end
  
    def self.between_faces(faces)
      new(faces.collect { |e| e.color })
    end
  
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
  
    ELEMENTS = generate_parts
    
    def num_incarnations(cube_size)
      if cube_size >= 2 then 1 else 0 end
    end
  
    # One index of such a piece on a on a NxN face.
    def base_index_on_face(cube_size, incarnation_index)
      [0, 0]
    end
  end
  
  class XCenter < MoveableCenter
    CORRESPONDING_PART_CLASS = Corner
    ELEMENTS = generate_parts
  
    def num_incarnations(cube_size)
      [cube_size / 2 - 1, 0].max
    end
  
    # One index of such a piece on a on a NxN face.
    def base_index_on_face(cube_size, incarnation_index)
      [1 + incarnation_index, 1 + incarnation_index]
    end
  end
  
  class TCenter < MoveableCenter
    CORRESPONDING_PART_CLASS = Edge
    ELEMENTS = generate_parts
  
    def num_incarnations(cube_size)
      if cube_size % 2 == 0
        0
      else
        [cube_size / 2 - 1, 0].max
      end
    end
    
    # One index of such a piece on a on a NxN face.
    def base_index_on_face(cube_size, incarnation_index)
      [1 + incarnation_index, cube_size / 2]
    end
  end

end
