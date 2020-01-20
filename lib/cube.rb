require 'cube_constants'
require 'coordinate'

module CubeTrainer

  class Part

    include CubeConstants
    
    def initialize(face_symbols)
      clazz = self.class
      if face_symbols.any? { |c| c.class != Symbol || !FACE_SYMBOLS.include?(c) }
        raise ArgumentError, "Faces symbols contain invalid item: #{face_symbols.inspect}"
      end
      if face_symbols.length != clazz::FACES
        raise ArgumentError, "Invalid number of face symbols #{face_symbols.length} for #{clazz}. Must be #{clazz::FACES}. Got face symbols: #{face_symbols.inspect}"
      end
      if face_symbols.uniq != face_symbols
        raise ArgumentError, "Non-unique face symbols #{face_symbols} for #{clazz}."
      end
      @face_symbols = face_symbols
    end
  
    def self.generate_parts
      parts = FACE_SYMBOLS.permutation(self::FACES).collect { |p| new(p) }.select { |p| p.valid? }.sort_by { |p| p.priorities }
      raise "Generated #{parts.length} parts for #{self}, but the alphabet size is only #{ALPHABET_SIZE}." unless parts.length <= ALPHABET_SIZE
      parts
    end
  
    def self.for_face_symbols_internal(face_symbols)
      raise unless face_symbols.length == self::FACES
      self::ELEMENTS.find { |e| e.face_symbols == face_symbols }
    end

    def self.for_face_symbols(face_symbols)
      for_face_symbols_internal(face_symbols)
    end

    def self.for_index(i)
      self::ELEMENTS[i]
    end
  
    def encode_with(coder)
      coder['face_symbols'] = @face_symbols
    end

    def <=>(other)
      piece_index <=> other.piece_index
    end

    include Comparable
  
    def eql?(other)
      self.class.equal?(other.class) && @face_symbols == other.face_symbols
    end
  
    alias == eql?
  
    def hash
      @face_symbols.hash
    end
  
    attr_reader :face_symbols
  
    def priorities
      @face_symbols.collect { |c| FACE_SYMBOLS.index(c) }
    end
  
    def inspect
      self.class.to_s + "(" + @face_symbols.collect { |c| c.to_s }.join(", ") + ")"
    end

    def to_s
      self.corresponding_part.face_symbols.collect.with_index do |c, i|
        face_name = FACE_NAMES[FACE_SYMBOLS.index(c)]
        if i < self.class::FACES then face_name else face_name.downcase end
      end.join
    end

    def piece_index
      self.class::ELEMENTS.index(self)
    end
  
    # Rotate a piece such that the given face symbol is the first face symbol.
    def rotate_face_symbol_up(c)
      index = @face_symbols.index(c)
      raise "Part #{self} doesn't have face symbol #{c}." unless index
      rotate_by(index)
    end

    def rotate_face_up(f)
      rotate_face_symbol_up(f.face_symbol)
    end

    def rotate_by(n)
      self.class.new(@face_symbols.rotate(n))
    end
  
    def inverse
      self.class.new(@face_symbols.reverse)
    end

    def has_face_symbol?(c)
      @face_symbols.include?(c)
    end
  
    # Returns true if the pieces are equal modulo rotation.
    def turned_equals?(other)
      @face_symbols.include?(other.face_symbols.first) && rotate_face_symbol_up(other.face_symbols.first) == other
    end
  
    def rotations
      (0...@face_symbols.length).collect { |i| rotate_by(i) }
    end
  
    def self.create_for_face_symbols(face_symbols)
      self.new(face_symbols)
    end
  
    def self.parse(piece_description)
      face_symbols = piece_description.upcase.strip.split('').collect do |e|
        FACE_SYMBOLS[FACE_NAMES.index(e)] || (raise "Invalid #{self.name} #{piece_description}: #{e} is not a valid face name.")
      end
      for_face_symbols(face_symbols)
    end
  
    # Only overridden by moveable centers, but returns self for convenience.
    def corresponding_part
      self
    end

    # The primary face that this piece is in in the solved state.
    def solved_face
      @solved_face ||= Face.for_face_symbol(@face_symbols.first)
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
          other_face_symbols = corresponding_part.face_symbols[1..-1].sort
          coordinate = base_coordinate.rotations.find do |coordinate|
            face_symbols_closeby = coordinate.close_neighbor_faces.map { |f| f.face_symbol }
            face_symbols_closeby.sort == other_face_symbols
          end
          raise "Couldn't find a fitting coordinate on the solved face." if coordinate.nil?
          coordinate
        end
    end
  end
  
  # This is an unmoveable center piece, it's mostly used as a helper class for other pieces.
  class Face < Part
    FACES = 1
  
    def self.for_face_symbol(face_symbol)
      for_face_symbols([face_symbol])
    end
    
    # Whether closeness to this face results in smaller indices for the stickers of other faces.
    def close_to_smaller_indices?
      piece_index < 3
    end
  
    def opposite
      Face.for_face_symbol(opposite_face_symbol(face_symbol))
    end

    def same_axis?(other)
      axis_priority == other.axis_priority
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
      @axis_priority ||= [piece_index, CubeConstants::FACES - 1 - piece_index].min
    end

    def is_canonical_axis_face?
      axis_priority < 3
    end
  
    def valid?
      true
    end
  
    def name
      @name ||= FACE_NAMES[ELEMENTS.index(self)]
    end
  
    def self.by_name(name)
      index = FACE_NAMES.index(name.upcase)
      raise "#{name} is not a valid #{self.class.name}." unless index
      ELEMENTS[index]
    end
  
    def face_symbol
      @face_symbols[0]
    end
  
    # Neighbor faces in clockwise order.
    def neighbors
      @neighbors ||= begin
                       partial_neighbors = self.class::ELEMENTS.select { |e| e != chirality_canonicalize && e == e.chirality_canonicalize }
                       ordered_partial_neighbors = if Corner.create_between_faces([self] + partial_neighbors).valid?
                                                     partial_neighbors
                                                   elsif Corner.create_between_faces([self] + partial_neighbors.reverse).valid?
                                                     partial_neighbors.reverse
                                                   else
                                                     raise "Couldn't find a proper order for the neighbor faces #{partial_neighbors.inspect} of #{inspect}."
                                                   end
                       ordered_partial_neighbors + ordered_partial_neighbors.collect { |e| e.opposite }
                     end
    end

    def clockwise_neighbor_after(neighbor)
      raise ArgumentError unless neighbors.include?(neighbor)
      @neighbors[(@neighbors.index(neighbor) + 1) % @neighbors.length]
    end

    # Returns either the face or its opposite face, depending which one is used in CHIRALITY_FACE_SYMBOLS.
    def chirality_canonicalize
      if CHIRALITY_FACE_SYMBOLS.include?(face_symbol)
        self
      else
        opposite
      end
    end

    # Returns the algorithm that performs a rotation after which the current face will
    # lie where the given other face currently is.
    def rotation_to(other)
      if other == self
        Algorithm.empty
      else
        axis_face = self.class::ELEMENTS.find { |e| e != chirality_canonicalize && e != other.chirality_canonicalize }
        direction = if other == self.opposite
                      CubeDirection::DOUBLE
                    else
                      if close_to_smaller_indices? ^ other.close_to_smaller_indices? ^ (axis_priority > other.axis_priority)
                        CubeDirection::FORWARD
                      else
                        CubeDirection::BACKWARD
                      end
                    end
        Algorithm.new([Rotation.new(axis_face, direction)])
      end
    end

    def clockwise_corners
      neighbors.zip(neighbors.rotate).map { |a, b| Corner.between_faces([self, a, b]) }
    end
  
    ELEMENTS = generate_parts
    FACE_SYMBOLS.map { |s| const_set(s, for_face_symbol(s)) }
  end
  
  class MoveableCenter < Part
    FACES = 1
  
    def initialize(corresponding_part)
      raise "Invalid corresponding part #{corresponding_part}." unless corresponding_part.is_a?(Part)
      super([corresponding_part.face_symbols[0]])
      @corresponding_part = corresponding_part
    end

    def self.for_face_symbols(face_symbols)
      raise ArgumentError, "Need #{self::CORRESPONDING_PART_CLASS::FACES} face_symbols for a #{self.class}, have #{face_symbols.inspect}." unless face_symbols.length == self::CORRESPONDING_PART_CLASS::FACES
      corresponding_part = self::CORRESPONDING_PART_CLASS.for_face_symbols(face_symbols)
      nil unless corresponding_part
      self::ELEMENTS.find { |e| e.corresponding_part == corresponding_part }
    end
  
    def self.create_for_face_symbols(face_symbols)
      self.new(self::CORRESPONDING_PART_CLASS.create_for_face_symbols(face_symbols))
    end
  
    def face_symbol
      @face_symbols[0]
    end
  
    def encode_with(coder)
      coder['corresponding_part'] = @corresponding_part
    end
  
    def eql?(other)
      self.class.equal?(other.class) && face_symbol == other.face_symbol && @corresponding_part == other.corresponding_part
    end
    
    alias == eql?
  
    def hash
      ([face_symbol, @index]).hash
    end
  
    attr_reader :face_symbols, :corresponding_part
  
    def priorities
      @corresponding_part.priorities
    end
  
    def inspect
      self.class.to_s + "(" + face_symbol.to_s + ", " + @corresponding_part.inspect + ")"
    end
  
    def rotate_by(n)
      self
    end
  
    def inverse
      self
    end
    
    def valid?
      @corresponding_part.valid?
    end
  
    def neighbor?(other)
      face_symbol == other.face_symbol
    end
  
    def neighbors
      self.class::ELEMENTS.select { |p| neighbor?(p) }
    end
  
    def self.generate_parts
      self::CORRESPONDING_PART_CLASS::ELEMENTS.collect { |p| new(p) }.sort_by { |p| p.priorities }
    end
  end

  module EdgeLike
    include CubeConstants

    def valid?
      !OPPOSITE_FACE_SYMBOLS.any? { |ss| ss.sort == @face_symbols.sort }
    end
  end
  
  class Edge < Part
    FACES = 2

    include EdgeLike
  
    ELEMENTS = generate_parts

    # Edges on uneven bigger cubes are midges, so edges only exist for 3x3.
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

    include EdgeLike
  
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
  
    include EdgeLike
  
    def self.for_face_symbols(face_symbols)
      # One additional face symbol is usually mentioned for wings.
      raise unless face_symbols.length == FACES || face_symbols.length == FACES + 1
      if face_symbols.length == 3
        valid = Corner.new(face_symbols).valid?
        reordered_face_symbols = face_symbols.dup
        reordered_face_symbols[0], reordered_face_symbols[1] = reordered_face_symbols[1], reordered_face_symbols[0]
        reordered_valid = Corner.new(reordered_face_symbols).valid?
        raise "Couldn't determine chirality for #{face_symbols.inspect} which is needed to parse a wing." if valid == reordered_valid
        if valid then for_face_symbols(face_symbols[0..1]) else for_face_symbols_internal(reordered_face_symbols[0..1]) end
      else
        for_face_symbols_internal(face_symbols)
      end
    end
  
    def corresponding_part
      @corresponding_part ||= begin
                                corners = FACE_SYMBOLS.select { |c| !@face_symbols.include?(c) }.collect { |c| Corner.new(@face_symbols + [c]) }.select { |c| c.valid? }
                                only(corners)
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
      inverse = solved_face.piece_index % 2 == 0
      coordinates = [0, 1 + incarnation_index]
      if inverse then coordinates.reverse else coordinates end
    end
  end
  
  class Corner < Part
    FACES = 3
    CHIRALITY_CORNER = Corner.new(CHIRALITY_FACE_SYMBOLS)
  
    def self.create_for_face_symbols(face_symbols)
      piece_candidates = face_symbols[1..-1].permutation.collect { |cs| new([face_symbols[0]] + cs) }
      pieces = piece_candidates.select { |p| p.valid? }
      raise "#{piece_description} is not unique to create a #{self}: #{pieces.inspect}" unless pieces.length == 1
      pieces.first
    end

    def self.for_face_symbols(face_symbols)
      raise "Invalid number of face_symbols to create a corner: #{face_symbols.inspect}" unless face_symbols.length == FACES
      for_face_symbols_internal(face_symbols) || for_face_symbols_internal([face_symbols[0], face_symbols[2], face_symbols[1]])
    end
  
    def self.create_between_faces(faces)
      new(faces.collect { |e| e.face_symbol })
    end

    def self.between_faces(faces)
      for_face_symbols(faces.collect { |e| e.face_symbol })
    end

    # Rotate such that neither the current face symbol nor the given face symbol are at the position of the letter.
    def rotate_other_face_symbol_up(face_symbol)
      index = @face_symbols.index(face_symbol)
      raise "Part #{self} doesn't have face symbol #{face_symbol}." unless index
      raise "Part #{self} already has face symbol #{face_symbol} up, so `rotate_other_face_symbol_up(#{face_symbol}) is invalid." if index == 0
      rotate_by(3 - index)
    end
  
    def rotate_other_face_up(f)
      rotate_other_face_symbol_up(f.face_symbol)
    end

    def valid?
      adjacent_edges.all? { |e| e } && valid_chirality?
    end

    def has_common_edge_with?(other)
      common_faces(other) == 2
    end
  
    def common_faces(other)
      raise TypeError unless other.is_a?(Corner)
      (@face_symbols & other.face_symbols).length
    end
  
    def adjacent_edges
      @adjacent_edges ||= @face_symbols.combination(2).collect { |e| Edge.for_face_symbols(e) }
    end
  
    def adjacent_faces
      @adjacent_faces ||= @face_symbols.collect { |f| Face.for_face_symbol(f) }
    end
  
    def valid_chirality?
      # To make it comparable to our CHIRALITY_CORNER, we switch each face used in c
      # different from the ones used in the CHIRALITY_CORNER for the opposite face.
      canonical_face_symbols = adjacent_faces.collect { |f| f.chirality_canonicalize.face_symbol }
      canonical_corner = Corner.new(canonical_face_symbols)
  
      # Each time we swap a face for the opposite, the chirality direction should be inverted.
      no_swapped_faces = canonical_face_symbols.zip(@face_symbols).count { |a, b| a != b }
      inverted = no_swapped_faces % 2 == 1
      inverted_corner = if inverted then canonical_corner.inverse else canonical_corner end
  
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
