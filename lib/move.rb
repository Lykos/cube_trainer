require 'cube'

DIRECTION_NAMES = ['', '2', '\'']
AXES = ['x', 'y', 'z']
MOVE_REGEXP = Regexp.new("(?:([#{AXES.join}])|(\\d*)([#{FACE_NAMES.join}])w|([#{FACE_NAMES.join}])|([#{FACE_NAMES.join.downcase}]))([#{DIRECTION_NAMES.join}]?)")

class Rotation
  def initialize(axis, direction)
    raise unless AXES.include?(axis)
    raise unless direction.is_a?(Integer) && 0 <= direction && direction < 4
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
    "#{@axis}#{DIRECTIONS[@direction - 1]}"
  end
end

class FatMove
  def initialize(face_name, width, direction)
    raise "Invalid face name #{face_name} for fat move." unless FACE_NAMES.include?(face_name)
    raise "Invalid width #{width} for fat move." unless width.is_a?(Integer) and width >= 1
    raise unless direction.is_a?(Integer) && 0 <= direction && direction < 4
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
    "#{if @width > 1 then @width else '' end}#{@face_name}#{if @width > 1 then 'w' else '' end}#{DIRECTION_NAMES[@direction - 1]}"
  end
end

class SliceMove
  def initialize(slice_name, direction)
    raise unless slice_name.downcase == slice_name
    raise unless FACE_NAMES.include?(slice_name.upcase)
    raise unless direction.is_a?(Integer) && 0 <= direction && direction < 4
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
    "#{@slice_name}#{DIRECTION_NAMES[@direction - 1]}"
  end
end

def parse_move(move_string)
  match = move_string.match(MOVE_REGEXP)
  raise "Invalid move #{move_string}." if !match || !match.pre_match.empty? || !match.post_match.empty?
  rotation, width, fat_face_name, face_name, slice_name, direction_string = match.captures
  direction = DIRECTION_NAMES.index(direction_string) + 1
  if rotation
    raise unless width.nil? && fat_face_name.nil? && face_name.nil? && slice_name.nil?
    Rotation.new(rotation, direction)
  elsif fat_face_name
    raise unless rotation.nil? && face_name.nil? && slice_name.nil?
    width = if width == '' then 2 else width.to_i end
    FatMove.new(fat_face_name, width, direction)
  elsif face_name
    raise unless rotation.nil? && width.nil? && fat_face_name.nil? && slice_name.nil?
    FatMove.new(face_name, 1, direction)
  elsif slice_name
    raise unless rotation.nil? && width.nil? && fat_face_name.nil? && face_name.nil?
    SliceMove.new(slice_name, direction)
  else
    raise
  end
end
