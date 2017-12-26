require 'cube'

# One move on the cube
class Move
  DIRECTIONS = ['', '2', '\'']
  ROTATIONS = ['x', 'y', 'z']
  REGEXP = Regexp.new("([#{ROTATIONS.join}]|\\d*[#{FACE_NAMES.join}]w|[#{FACE_NAMES.join}]|[#{FACE_NAMES.join.downcase}])([#{DIRECTIONS.join}]?)")
  
  def initialize(move_string)
    match = move_string.match(REGEXP)
    raise "Invalid move #{move_string}." if !match || !match.pre_match.empty? || !match.post_match.empty?
    @face, @direction = match.captures
  end

  attr_reader :face, :direction

  def eql?(other)
    self.class.equal?(other.class) && @face == other.face && @direction == other.direction
  end

  alias == eql?

  def hash
    [@face, @direction].hash
  end

  def to_s
    @face + @direction
  end
end
