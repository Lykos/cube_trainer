require 'cube'

DIRECTIONS = ['', '2', '\'']
AXES = ['x', 'y', 'z']
MOVE_REGEXP = Regexp.new("(?:([#{AXES.join}])|(\\d*)([#{FACE_NAMES.join}])w|([#{FACE_NAMES.join}])|([#{FACE_NAMES.join.downcase}]))([#{DIRECTIONS.join}]?)")

class Rotation
  def initialize(axis, direction)
    raise unless AXES.include?(axis)
    raise unless DIRECTIONS.include?(direction)
    @axis = axis
    @direction = direction
  end

  attr_reader :axis, :direction

  def eql?(other)
    self.class.equal?(other.class) && @axis == other.axis && @direction == other.direction
  end

  alias == eql?

  def hash
    [@axis, @direction].hash
  end

  def to_s
    @axis + @direction
  end
end

class NormalMove
  def initialize(face_name, direction)
    raise unless FACE_NAMES.include?(face_name)
    raise unless DIRECTIONS.include?(direction)
    @face_name = face_name
    @direction = direction
  end

  attr_reader :face_name, :direction

  def eql?(other)
    self.class.equal?(other.class) && @face_name == other.face_name && @direction == other.direction
  end

  alias == eql?

  def hash
    [@face_name, @direction].hash
  end

  def to_s
    @face_name + @direction
  end
end

class FatMove
  def initialize(face_name, width, direction)
    raise "Invalid face name #{face_name} for fat move." unless FACE_NAMES.include?(face_name)
    raise "Invalid width #{width} for fat move." unless width.is_a?(Integer) and width > 1
    raise unless DIRECTIONS.include?(direction)
    @face_name = face_name
    @width = width
    @direction = direction
  end

  attr_reader :face_name, :width, :direction

  def eql?(other)
    self.class.equal?(other.class) && @face_name == other.face_name && @width == other.width && @direction == other.direction
  end

  alias == eql?

  def hash
    [@face_name, @width, @direction].hash
  end

  def to_s
    "#{@width}#{@face_name}w#{@direction}"
  end
end

class SliceMove
  def initialize(slice_name, direction)
    raise unless slice_name.downcase == slice_name
    raise unless FACE_NAMES.include?(slice_name.upcase)
    raise unless DIRECTIONS.include?(direction)
    @slice_name = slice_name
    @direction = direction
  end

  attr_reader :slice_name, :direction

  def eql?(other)
    self.class.equal?(other.class) && @slice_name == other.slice_name && @direction == other.direction
  end

  alias == eql?

  def hash
    [@slice_name, @direction].hash
  end

  def to_s
    @slice_name + @direction
  end
end

def parse_move(move_string)
  match = move_string.match(MOVE_REGEXP)
  raise "Invalid move #{move_string}." if !match || !match.pre_match.empty? || !match.post_match.empty?
  rotation, width, fat_face_name, face_name, slice_name, direction = match.captures
  if rotation
    raise unless width.nil? && fat_face_name.nil? && face_name.nil? && slice_name.nil?
    Rotation.new(rotation, direction)
  elsif fat_face_name
    raise unless rotation.nil? && face_name.nil? && slice_name.nil?
    width = if width == '' then 2 else width.to_i end
    FatMove.new(fat_face_name, width, direction)
  elsif face_name
    raise unless rotation.nil? && width.nil? && fat_face_name.nil? && slice_name.nil?
    NormalMove.new(face_name, direction)
  elsif slice_name
    raise unless rotation.nil? && width.nil? && fat_face_name.nil? && face_name.nil?
    SliceMove.new(slice_name, direction)
  else
    raise
  end
end
