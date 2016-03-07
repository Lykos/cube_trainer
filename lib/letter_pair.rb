class LetterPair

  def initialize(letters)
    @letters = letters
  end

  attr_reader :letters

  def encode_with(coder)
    coder['letters'] = @letters
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
