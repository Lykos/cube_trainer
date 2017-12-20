require 'cube'

class LetterPair

  SEPARATOR = " "
  raise if ALPHABET.include?(SEPARATOR)
  
  def initialize(letters)
    raise unless 1 <= letters.length and letters.length < 3
    raise unless letters.all? { |l| ALPHABET.include?(l) }
    @letters = letters
  end

  attr_reader :letters

  # Encoding for YAML (and possibly others)
  def encode_with(coder)
    coder['letters'] = @letters
  end

  # Construct from data stored in the db.
  def self.from_raw_data(data)
    LetterPair.new(data.split(SEPARATOR))
  end

  # Serialize to data stored in the db.
  def to_raw_data
    @letters.join(SEPARATOR)
  end

  def eql?(other)
    self.class.equal?(other.class) && @letters == other.letters
  end

  alias == eql?

  def hash
    @letters.hash
  end

  def to_s
    @to_s ||= letters.collect { |l| l.capitalize }.join(' ')
  end

  def regexp
    @regexp ||= Regexp.new('^' + @letters.join('.*'), Regexp::IGNORECASE)
  end

  def matches_word?(word)
    word =~ regexp
  end
end
