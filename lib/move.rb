require 'cube'
require 'cube_state'

module CubeTrainer

  SKEWB_MOVES = ['U', 'R', 'L', 'B']
  DIRECTION_NAMES = ['', '2', '\'']
  AXES = ['y', 'z', 'x']
  SLICES = ['E', 'S', 'M']
  MOVE_REGEXP = Regexp.new("(?:([#{AXES.join}])|(\\d*)([#{FACE_NAMES.join}])w|([#{FACE_NAMES.join}])|([#{FACE_NAMES.join.downcase}])|([#{SLICES.join}]))([#{DIRECTION_NAMES.join}]?)")
  SKEWB_MOVE_REGEXP = Regexp.new("([#{SKEWB_MOVES.join}])([#{DIRECTION_NAMES.join}]?)")

  # TODO class direction
  def invert_direction(direction)
    4 - direction
  end

  class Move
  end

  class MSliceMove < Move
    def initialize(axis_face, direction)
      raise ArgumentError unless axis_face.is_a?(Face) && Face::ELEMENTS.index(axis_face) < 3
      raise ArgumentError unless direction.is_a?(Integer) && 1 <= direction && direction < 4
      @axis_face = axis_face
      @direction = direction
    end
  
    attr_reader :axis_face, :direction
  
    def eql?(other)
      self.class.equal?(other.class) && @axis_face == other.axis_face && @direction == other.direction
    end
  
    alias == eql?
  
    def hash
      [@axis_face, @direction].hash
    end
  
    def to_s
      "#{SLICES[Face::ELEMENTS.index(@axis_face)]}#{DIRECTION_NAMES[@direction - 1]}"
    end
  
    def apply_to(cube_state)
      raise ArgumentError unless cube_state.is_a?(CubeState)
      raise ArgumentError if cube_state.n % 2 == 0
      s = cube_state.n / 2
      cube_state.rotate_slice(@axis_face, s, @direction)
    end

    def invert
      MSliceMove.new(@axis_face, invert_direction(@direction))
    end
  end
  
  class Rotation < Move
    def initialize(axis_face, direction)
      raise ArgumentError unless axis_face.is_a?(Face) && Face::ELEMENTS.index(axis_face) < 3
      raise ArgumentError unless direction.is_a?(Integer) && 1 <= direction && direction < 4
      @axis_face = axis_face
      @direction = direction
    end
  
    attr_reader :axis_face, :direction
  
    def eql?(other)
      self.class.equal?(other.class) && @axis_face == other.axis_face && @direction == other.direction
    end
  
    alias == eql?
  
    def hash
      [@axis_face, @direction].hash
    end
  
    def to_s
      "#{AXES[Face::ELEMENTS.index(@axis_face)]}#{DIRECTION_NAMES[@direction - 1]}"
    end
  
    def apply_to(cube_state)
      # TODO Skewb
      raise ArgumentErorr unless cube_state.is_a?(CubeState)
      0.upto(cube_state.n - 1) do |s|
        cube_state.rotate_slice(@axis_face, s, @direction)
      end
      cube_state.rotate_face(@axis_face, @direction)
      cube_state.rotate_face(@axis_face.opposite, invert_direction(@direction))
    end

    def invert
      Rotation.new(@axis_face, invert_direction(@direction))
    end
  end

  class SkewbMove < Move
    def initialize(move, direction)
      raise ArgumentError unless SKEWB_MOVES.include?(move)
      raise ArgumentError unless direction.is_a?(Integer) && 1 <= direction && direction < 3
      @move = move
      @direction = direction
    end

    ALL = [new('U', 1), new('U', 2), new('R', 1), new('R', 2), new('L', 1), new('L', 2), new('B', 1), new('B', 2)]

    attr_reader :move, :direction
  
    def eql?(other)
      self.class.equal?(other.class) && @move == other.move && @direction == other.direction
    end
  
    alias == eql?
  
    def hash
      [@move, @direction].hash
    end

    def skewb_direction_name(direction)
      if direction == 1
        DIRECTION_NAMES[0]
      elsif direction == 2
        DIRECTION_NAMES[-1]
      else
        raise ArugmentError
      end
    end

    def invert_skewb_direction(direction)
      3 - direction
    end

    def to_s
      "#{@move}#{skewb_direction_name(@direction)}"
    end

    def apply_to(cube_state)
      raise ArgumentError unless cube_state.is_a?(SkewbState)
      # I haven't found a better way for Skewb than to hardcode what each move does.
      cycles = case @move
               when 'U'
                 [[SkewbCoordinate.center(Face.for_color(:blue)), SkewbCoordinate.center(Face.for_color(:white)), SkewbCoordinate.center(Face.for_color(:orange))],
                  [SkewbCoordinate.new(Face.for_color(:blue), 2), SkewbCoordinate.new(Face.for_color(:white), 2), SkewbCoordinate.new(Face.for_color(:orange), 1)],
                  [SkewbCoordinate.new(Face.for_color(:blue), 3), SkewbCoordinate.new(Face.for_color(:white), 3), SkewbCoordinate.new(Face.for_color(:orange), 4)],
                  [SkewbCoordinate.new(Face.for_color(:blue), 4), SkewbCoordinate.new(Face.for_color(:white), 4), SkewbCoordinate.new(Face.for_color(:orange), 3)],
                  [SkewbCoordinate.new(Face.for_color(:yellow), 3), SkewbCoordinate.new(Face.for_color(:red), 4), SkewbCoordinate.new(Face.for_color(:green), 3)]]
               when 'R'
                 [[SkewbCoordinate.center(Face.for_color(:yellow)), SkewbCoordinate.center(Face.for_color(:red)), SkewbCoordinate.center(Face.for_color(:blue))],
                  [SkewbCoordinate.new(Face.for_color(:yellow), 1), SkewbCoordinate.new(Face.for_color(:red), 3), SkewbCoordinate.new(Face.for_color(:blue), 1)],
                  [SkewbCoordinate.new(Face.for_color(:yellow), 2), SkewbCoordinate.new(Face.for_color(:red), 4), SkewbCoordinate.new(Face.for_color(:blue), 3)],
                  [SkewbCoordinate.new(Face.for_color(:yellow), 3), SkewbCoordinate.new(Face.for_color(:red), 1), SkewbCoordinate.new(Face.for_color(:blue), 2)],
                  [SkewbCoordinate.new(Face.for_color(:green), 2), SkewbCoordinate.new(Face.for_color(:white), 3), SkewbCoordinate.new(Face.for_color(:orange), 1)]]
               when 'L'
                 [[SkewbCoordinate.center(Face.for_color(:yellow)), SkewbCoordinate.center(Face.for_color(:orange)), SkewbCoordinate.center(Face.for_color(:green))],
                  [SkewbCoordinate.new(Face.for_color(:yellow), 2), SkewbCoordinate.new(Face.for_color(:orange), 1), SkewbCoordinate.new(Face.for_color(:green), 3)],
                  [SkewbCoordinate.new(Face.for_color(:yellow), 3), SkewbCoordinate.new(Face.for_color(:orange), 4), SkewbCoordinate.new(Face.for_color(:green), 2)],
                  [SkewbCoordinate.new(Face.for_color(:yellow), 4), SkewbCoordinate.new(Face.for_color(:orange), 2), SkewbCoordinate.new(Face.for_color(:green), 1)],
                  [SkewbCoordinate.new(Face.for_color(:red), 1), SkewbCoordinate.new(Face.for_color(:blue), 3), SkewbCoordinate.new(Face.for_color(:white), 2)]]
               when 'B'
                 [[SkewbCoordinate.center(Face.for_color(:yellow)), SkewbCoordinate.center(Face.for_color(:blue)), SkewbCoordinate.center(Face.for_color(:orange))],
                  [SkewbCoordinate.new(Face.for_color(:yellow), 1), SkewbCoordinate.new(Face.for_color(:blue), 4), SkewbCoordinate.new(Face.for_color(:orange), 2)],
                  [SkewbCoordinate.new(Face.for_color(:yellow), 3), SkewbCoordinate.new(Face.for_color(:blue), 3), SkewbCoordinate.new(Face.for_color(:orange), 1)],
                  [SkewbCoordinate.new(Face.for_color(:yellow), 4), SkewbCoordinate.new(Face.for_color(:blue), 1), SkewbCoordinate.new(Face.for_color(:orange), 3)],
                  [SkewbCoordinate.new(Face.for_color(:red), 3), SkewbCoordinate.new(Face.for_color(:white), 4), SkewbCoordinate.new(Face.for_color(:green), 1)]]
               else
                 raise
               end
      cycles.each do |c|
        if @direction == 1
          cube_state.apply_index_cycle(c)
        elsif @direction == 2
          cube_state.apply_index_cycle(c.reverse)
        else
          raise
        end
      end
    end

    def invert
      SkewbMove.new(@move, invert_skewb_direction(@direction))
    end
  
  end
  
  class FatMove < Move
    def initialize(face, width, direction)
      raise ArgumentError unless face.is_a?(Face)
      raise ArgumentError, "Invalid width #{width} for fat move." unless width.is_a?(Integer) and width >= 1
      raise ArgumentError unless direction.is_a?(Integer) && 1 <= direction && direction < 4
      @face = face
      @width = width
      @direction = direction
    end
  
    attr_reader :face, :width, :direction
  
    def eql?(other)
      self.class.equal?(other.class) && @face == other.face && @width == other.width && @direction == other.direction
    end
  
    alias == eql?
  
    def hash
      [@face, @width, @direction].hash
    end
  
    def to_s
      "#{if @width > 1 then @width else '' end}#{@face.name}#{if @width > 1 then 'w' else '' end}#{DIRECTION_NAMES[@direction - 1]}"
    end
  
    def apply_to(cube_state)
      raise ArgumentError unless cube_state.is_a?(CubeState)
      raise if @width >= cube_state.n
      0.upto(@width - 1) do |s|
        cube_state.rotate_slice(@face, s, @direction)
      end
      cube_state.rotate_face(@face, @direction)
    end

    def invert
      FatMove.new(@face, @width, invert_direction(@direction))
    end
  end
  
  class SliceMove < Move
    def initialize(slice_face, direction)
      raise ArgumentError unless slice_face.is_a?(Face)
      raise ArgumentError unless direction.is_a?(Integer) && 1 <= direction && direction < 4
      @slice_face = slice_face
      @direction = direction
    end
  
    attr_reader :slice_face, :direction
  
    def eql?(other)
      self.class.equal?(other.class) && @slice_face == other.slice_face && @direction == other.direction
    end
  
    alias == eql?
  
    def hash
      [@slice_face, @direction].hash
    end
  
    def to_s
      "#{@slice_face.name.downcase}#{DIRECTION_NAMES[@direction - 1]}"
    end
  
    def apply_to(cube_state)
      raise ArgumentError unless cube_state.is_a?(CubeState)
      cube_state.rotate_slice(@slice_face, 1, @direction)
    end

    def invert
      SliceMove.new(@slice_face, invert_direction(@direction))
    end
  end

  class Algorithm
    def initialize(moves)
      moves.each do |m|
        raise ArgumentError, "#{m.inspect} is not a suitable move." unless m.is_a?(Move)
      end
      @moves = moves
    end

    EMPTY_ALGORITHM = Algorithm.new([])

    def self.empty
      EMPTY_ALGORITHM
    end

    attr_reader :moves

    def eql?(other)
      self.class.equal?(other.class) && @moves == other.moves
    end
  
    alias == eql?
  
    def hash
      @moves.hash
    end

    def length
      @moves.length
    end
  
    def to_s
      @moves.join(' ')
    end

    def apply_to(cube_state)
      @moves.each { |m| m.apply_to(cube_state) }
    end

    def invert
      Algorithm.new(@moves.reverse.collect { |m| m.invert })
    end

    def +(other)
      Algorithm.new(@moves + other.moves)
    end
  end
  
  def parse_move(move_string)
    match = move_string.match(MOVE_REGEXP)
    raise "Invalid move #{move_string}." if !match || !match.pre_match.empty? || !match.post_match.empty?
    rotation, width, fat_face_name, face_name, slice_name, mslice_name, direction_string = match.captures
    direction = DIRECTION_NAMES.index(direction_string) + 1
    if rotation
      raise unless width.nil? && fat_face_name.nil? && face_name.nil? && slice_name.nil?
      Rotation.new(Face::ELEMENTS[AXES.index(rotation)], direction)
    elsif fat_face_name
      raise unless rotation.nil? && face_name.nil? && slice_name.nil?
      width = if width == '' then 2 else width.to_i end
      FatMove.new(Face.by_name(fat_face_name), width, direction)
    elsif face_name
      raise unless rotation.nil? && width.nil? && fat_face_name.nil? && slice_name.nil?
      FatMove.new(Face.by_name(face_name), 1, direction)
    elsif slice_name
      raise unless rotation.nil? && width.nil? && fat_face_name.nil? && face_name.nil?
      SliceMove.new(Face.by_name(slice_name.upcase), direction)
    elsif mslice_name
      raise unless rotation.nil? && width.nil? && fat_face_name.nil? && face_name.nil?
      fixed_direction = if mslice_name == 'S' then direction else invert_direction(direction) end
      MSliceMove.new(Face::ELEMENTS[SLICES.index(mslice_name)], fixed_direction)
    else
      raise
    end
  end

  # Parses WCA Skewb moves.
  def parse_skewb_move(move_string)
    match = move_string.match(SKEWB_MOVE_REGEXP)
    raise "Invalid move #{move_string}." if !match || !match.pre_match.empty? || !match.post_match.empty?
    skewb_move_string, direction_string = match.captures
    direction = if direction_string == DIRECTION_NAMES[0] then 1 elsif direction_string == DIRECTION_NAMES[-1] then 2 else raise end
    SkewbMove.new(skewb_move_string, direction)
  end

end
