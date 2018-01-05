require 'cube'

module CubeTrainer

  DIRECTION_NAMES = ['', '2', '\'']
  AXES = ['x', 'y', 'z']
  MOVE_REGEXP = Regexp.new("(?:([#{AXES.join}])|(\\d*)([#{FACE_NAMES.join}])w|([#{FACE_NAMES.join}])|([#{FACE_NAMES.join.downcase}]))([#{DIRECTION_NAMES.join}]?)")
  
  class Rotation
    def initialize(axis_face, direction)
      raise unless axis_face.is_a?(Face) && Face::ELEMENTS.index(axis_face) < 3
      raise unless direction.is_a?(Integer) && 0 <= direction && direction < 4
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
      0.upto(cube_state.n - 1) do |s|
        cube_state.rotate_slice(@axis_face, s, @direction)
      end
      cube_state.rotate_face(@axis_face, @direction)
      cube_state.rotate_face(@axis_face.opposite, 4 - @direction)
    end
  end
  
  class FatMove
    def initialize(face, width, direction)
      raise unless face.is_a?(Face)
      raise "Invalid width #{width} for fat move." unless width.is_a?(Integer) and width >= 1
      raise unless direction.is_a?(Integer) && 0 <= direction && direction < 4
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
      raise if @width >= cube_state.n
      0.upto(@width - 1) do |s|
        cube_state.rotate_slice(@face, s, @direction)
      end
      cube_state.rotate_face(@face, @direction)
    end
  end
  
  class SliceMove
    def initialize(slice_face, direction)
      raise unless slice_face.is_a?(Face)
      raise unless direction.is_a?(Integer) && 0 <= direction && direction < 4
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
      cube_state.rotate_slice(@slice_face, 2, @direction)
    end
  end
  
  def parse_move(move_string)
    match = move_string.match(MOVE_REGEXP)
    raise "Invalid move #{move_string}." if !match || !match.pre_match.empty? || !match.post_match.empty?
    rotation, width, fat_face_name, face_name, slice_name, direction_string = match.captures
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
    else
      raise
    end
  end

end
