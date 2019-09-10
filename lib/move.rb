require 'cube'
require 'cube_state'

module CubeTrainer

  SKEWB_MOVES = ['U', 'R', 'L', 'B']
  POSSIBLE_DIRECTION_NAMES = [[''], ['2', '2\''], ['\'', '3']]
  SIMPLE_DIRECTION_NAMES = POSSIBLE_DIRECTION_NAMES.map { |d| d.first }
  AXES = ['y', 'z', 'x']
  SLICES = ['E', 'S', 'M']

  class AbstractDirection    
    def initialize(value)
      raise ArgumentError, "Direction value #{value} isn't an integer." unless value.is_a?(Integer)
      raise ArgumentError, "Invalid direction value #{value}." unless 0 <= value && value < self.class::NUM_DIRECTIONS
      @value = value
    end

    attr_reader :value

    def is_non_zero?
      @value > 0
    end

    def invert
      self::class.new(self.class::NUM_DIRECTIONS - @value)
    end

    def +(other)
      self::class.new((@value + other.value) % self.class::NUM_DIRECTIONS)
    end
    
    def eql?(other)
      self.class.equal?(other.class) && @value == other.value
    end
  
    alias == eql?
  
    def hash
      @value.hash
    end
  end

  class SkewbDirection < AbstractDirection
    NUM_DIRECTIONS = 3
    NON_ZERO_DIRECTIONS = (1...NUM_DIRECTIONS).map { |d| new(d) }
    FORWARD = new(1)
    BACKWARD = new(2)

    def name
      case self
      when FORWARD
        SIMPLE_DIRECTION_NAMES[0]
      when BACKWARD
        SIMPLE_DIRECTION_NAMES[-1]
      else
        raise ArgumentError
      end
    end

    def is_double_move?
      false
    end
  end
  
  class CubeDirection < AbstractDirection
    NUM_DIRECTIONS = 4
    NON_ZERO_DIRECTIONS = (1...NUM_DIRECTIONS).map { |d| new(d) }

    def name
      raise ArgumentError unless is_non_zero?
      SIMPLE_DIRECTION_NAMES[@value - 1]
    end

    def is_double_move?
      @value == 2
    end
  end
  
  class Move
    MOVE_METRICS = [:qtm, :htm, :stm, :sqtm, :qstm]

    def self.check_move_metric(metric)
      raise ArgumentError, "Invalid move metric #{metric}." unless MOVE_METRICS.include?(metric)    
    end
    
    def move_count(metric=:htm)
      Move.check_move_metric(metric)
      slice_factor = if is_slice_move? then 2 else 1 end
      direction_factor = if direction.is_double_move? then 2 else 1 end
      case metric
      when :qtm
        slice_factor * direction_factor
      when :htm
        slice_factor
      when :stm
        1
      when :qstm
        direction_factor
      when :sqtm
        direction_factor
      else
        raise
      end
    end

    def is_slice_move?
      raise NotImplementedError
    end

    def direction
      raise NotImplementedError
    end

    def invert
      raise NotImplementedError
    end

    # Returns true if this move can be cancelled with the other one with nothing left after cancellation (not even rotations).
    def cancels_totally?(other)
      invert == other
    end
  end

  class MSliceMove < Move
    def initialize(axis_face, direction)
      raise ArgumentError unless axis_face.is_a?(Face) && Face::ELEMENTS.index(axis_face) < 3
      raise ArgumentError unless direction.is_a?(CubeDirection) && direction.is_non_zero?
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
      slice_name = SLICES[Face::ELEMENTS.index(@axis_face)]
      broken_direction = if slice_name == 'S' then direction else direction.invert end
      "#{slice_name}#{broken_direction.name}"
    end
  
    def apply_to(cube_state)
      raise ArgumentError unless cube_state.is_a?(CubeState)
      # For even layered cubes, m slice moves are meant as very fat moves where only the outer layers stay.
      # For odd layered cubes, we only move the very middle.
      if cube_state.n % 2 == 0
        1.upto(cube_state.n - 2) do |s|
          cube_state.rotate_slice(@axis_face, s, @direction)
        end
      else
        s = cube_state.n / 2
        cube_state.rotate_slice(@axis_face, s, @direction)
      end
    end

    def invert
      MSliceMove.new(@axis_face, @direction.invert)
    end

    def is_slice_move?
      true
    end

    def cancels_partially?(other)
      other.is_a?(MSliceMove) && @axis_face == other.axis_face
    end

    def cancel_partially(other)
      raise ArgumentError unless cancels_partially?(other)
      raise ArgumentError if cancels_totally?(other)
      MSliceMove.new(@axis_face, @direction + other.direction)
    end
  end
  
  class Rotation < Move
    def initialize(axis_face, direction)
      raise ArgumentError unless axis_face.is_a?(Face) && Face::ELEMENTS.index(axis_face) < 3
      raise ArgumentError unless direction.is_a?(CubeDirection) && direction.is_non_zero?
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
      "#{AXES[Face::ELEMENTS.index(@axis_face)]}#{@direction.name}"
    end
  
    def apply_to(cube_state)
      # TODO Skewb
      raise ArgumentErorr unless cube_state.is_a?(CubeState)
      0.upto(cube_state.n - 1) do |s|
        cube_state.rotate_slice(@axis_face, s, @direction)
      end
      cube_state.rotate_face(@axis_face, @direction)
      cube_state.rotate_face(@axis_face.opposite, @direction.invert)
    end

    def invert
      Rotation.new(@axis_face, @direction.invert)
    end

    def is_slice_move?
      false
    end

    def cancels_partially?(other)
      other.is_a?(Rotation) && @axis_face == other.axis_face
    end

    def cancel_partially(other)
      raise ArgumentError unless cancels_partially?(other)
      raise ArgumentError if cancels_totally?(other)
      Rotation.new(@axis_face, @direction + other.direction)
    end

    def move_count(metric=:htm)
      0
    end
  end

  class SkewbMove < Move
    def initialize(move, direction)
      raise ArgumentError unless SKEWB_MOVES.include?(move)
      raise ArgumentError unless direction.is_a?(SkewbDirection) && direction.is_non_zero?
      @move = move
      @direction = direction
    end

    ALL = SKEWB_MOVES.product(SkewbDirection::NON_ZERO_DIRECTIONS).map { |m, d| new(m, d) }

    attr_reader :move, :direction
  
    def eql?(other)
      self.class.equal?(other.class) && @move == other.move && @direction == other.direction
    end
  
    alias == eql?
  
    def hash
      [@move, @direction].hash
    end

    def to_s
      "#{@move}#{@direction.name}"
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
        case @direction
        when SkewbDirection::FORWARD
          cube_state.apply_index_cycle(c)
        when SkewbDirection::BACKWARD
          cube_state.apply_index_cycle(c.reverse)
        else
          raise ArgumentError
        end
      end
    end

    def invert
      SkewbMove.new(@move, @direction.invert)
    end

    def is_slice_move?
      false
    end
    
    def cancels_partially?(other)
      other.is_a?(SkewbMove) && @axis_face == other.axis_face
    end

    def cancel_partially(other)
      raise ArgumentError unless cancels_partially?(other)
      raise ArgumentError if cancels_totally?(other)
      SkewbMove.new(@axis_face, @direction + other.direction)
    end
  end
  
  class FatMove < Move
    def initialize(axis_face, width, direction)
      raise ArgumentError unless axis_face.is_a?(Face)
      raise ArgumentError, "Invalid width #{width} for fat move." unless width.is_a?(Integer) and width >= 1
      raise ArgumentError unless direction.is_a?(CubeDirection) && direction.is_non_zero?
      @axis_face = axis_face
      @width = width
      @direction = direction
    end

    OUTER_MOVES = Face::ELEMENTS.product(CubeDirection::NON_ZERO_DIRECTIONS).map { |f, d| FatMove.new(f, 1, d) }
  
    attr_reader :axis_face, :width, :direction

    def eql?(other)
      self.class.equal?(other.class) && @axis_face == other.axis_face && @width == other.width && @direction == other.direction
    end
  
    alias == eql?
  
    def hash
      [@axis_face, @width, @direction].hash
    end
  
    def to_s
      "#{if @width > 1 then @width else '' end}#{@axis_face.name}#{if @width > 1 then 'w' else '' end}#{@direction.name}"
    end
  
    def apply_to(cube_state)
      raise ArgumentError unless cube_state.is_a?(CubeState)
      raise if @width >= cube_state.n
      0.upto(@width - 1) do |s|
        cube_state.rotate_slice(@axis_face, s, @direction)
      end
      cube_state.rotate_face(@axis_face, @direction)
    end

    def invert
      FatMove.new(@axis_face, @width, @direction.invert)
    end

    def is_slice_move?
      false
    end

    def cancels_partially?(other)
      other.is_a?(FatMove) && @axis_face == other.axis_face && @width == other.width
    end

    def cancel_partially(other)
      raise ArgumentError unless cancels_partially?(other)
      raise ArgumentError if cancels_totally?(other)
      FatMove.new(@axis_face, @width, @direction + other.direction)
    end
  end
  
  class SliceMove < Move
    def initialize(axis_face, direction)
      raise ArgumentError unless axis_face.is_a?(Face)
      raise ArgumentError unless direction.is_a?(CubeDirection) && direction.is_non_zero?
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
      "#{@axis_face.name.downcase}#{@direction.name}"
    end
  
    def apply_to(cube_state)
      raise ArgumentError unless cube_state.is_a?(CubeState)
      # We handle the annoying inconsistency that u is a slice move for bigger cubes, but a fat move for 3x3.
      if cube_state.n == 3
        0.upto(1) do |s|
          cube_state.rotate_slice(@axis_face, s, @direction)
        end
        cube_state.rotate_face(@axis_face, @direction)
      else
        cube_state.rotate_slice(@axis_face, 1, @direction)
      end
    end

    def invert
      SliceMove.new(@axis_face, @direction.invert)
    end

    def is_slice_move?
      true
    end

    def cancels_partially?(other)
      other.is_a?(SliceMove) && @axis_face == other.axis_face
    end

    def cancel_partially(other)
      raise ArgumentError unless cancels_partially?(other)
      raise ArgumentError if cancels_totally?(other)
      SliceMove.new(@axis_face, @direction + other.direction)
    end
  end

  class CubeMoveParser
    REGEXP = begin
               axes_part = "([#{AXES.join}])"
               fat_move_part = "(\\d*)([#{FACE_NAMES.join}])w"
               normal_move_part = "([#{FACE_NAMES.join}])"
               small_move_part = "([#{FACE_NAMES.join.downcase}])"
               slice_move_part = "([#{SLICES.join}])"
               move_part = "(?:#{axes_part}|#{fat_move_part}|#{normal_move_part}|#{small_move_part}|#{slice_move_part})"
               direction_part = "(#{POSSIBLE_DIRECTION_NAMES.flatten.sort_by { |e| -e.length }.join("|")})"
               Regexp.new("#{move_part}#{direction_part}")
             end

    def regexp
      REGEXP
    end

    def parse_direction(direction_string)
      value = POSSIBLE_DIRECTION_NAMES.index { |ds| ds.include?(direction_string) } + 1
      CubeDirection.new(value)
    end
  
    def parse_move(move_string)
      match = move_string.match(REGEXP)
      raise "Invalid move #{move_string}." if !match || !match.pre_match.empty? || !match.post_match.empty?
      rotation, width, fat_face_name, face_name, slice_name, mslice_name, direction_string = match.captures
      direction = parse_direction(direction_string)
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
        fixed_direction = if mslice_name == 'S' then direction else direction.invert end
        MSliceMove.new(Face::ELEMENTS[SLICES.index(mslice_name)], fixed_direction)
      else
        raise
      end
    end

    INSTANCE = CubeMoveParser.new
  end

  class SkewbMoveParser
    REGEXP = Regexp.new("([#{SKEWB_MOVES.join}])([#{POSSIBLE_DIRECTION_NAMES.flatten.join}]?)")

    def regexp
      REGEXP
    end

    def parse_skewb_direction(direction_string)
      if POSSIBLE_DIRECTION_NAMES[0].include?(direction_string)
        SkewbDirection::FORWARD
      elsif POSSIBLE_DIRECTION_NAMES[-1].include?(direction_string)
        SkewbDirection::BACKWARD
      else
        raise ArgumentError
      end
    end

    # Parses WCA Skewb moves.
    def parse_move(move_string)
      match = move_string.match(REGEXP)
      raise "Invalid move #{move_string}." if !match || !match.pre_match.empty? || !match.post_match.empty?
      skewb_move_string, direction_string = match.captures
      direction = parse_skewb_direction(direction_string)
      SkewbMove.new(skewb_move_string, direction)
    end

    INSTANCE = SkewbMoveParser.new
  end

end
