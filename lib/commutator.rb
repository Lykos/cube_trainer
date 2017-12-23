require 'strscan'
require 'cube'

class CommutatorParseError < StandardError
end

class PureCommutator
  def initialize(first_part, second_part)
    @first_part = first_part
    @second_part = second_part
  end

  attr_reader :first_part, :second_part

  def invert
    PureCommutator.new(second_part, first_part)
  end

  def to_s
    "[#{@first_part.join(' ')}, #{@second_part.join(' ')}]"
  end
end

class SetupCommutator
  def initialize(setup, pure_commutator)
    @setup = setup
    @pure_commutator = pure_commutator
  end

  attr_reader :setup, :pure_commutator

  def invert
    SetupCommutator.new(setup, @pure_commutator.invert)
  end

  def to_s
    "[#{@setup.join(' ')} : #{@pure_commutator}]"
  end
end

class CommutatorParser 
  def initialize(alg_string)
    @alg_string = alg_string
    @scanner = StringScanner.new(alg_string)
  end

  # Parses at least one move.
  def parse_moves
    moves = []
    while m = begin skip_spaces; parse_move end
      moves.push(m)
    end
    complain('move') if moves.empty?
    moves
  end

  def complain(parsed_object)
    raise CommutatorParseError, "Couldn't parse #{parsed_object} at #{@scanner.pos} of #{@alg_string}." 
  end

  def parse_open_bracket
    complain('beginning of commutator') unless @scanner.getch == '['
  end
  
  def parse_close_bracket
    complain('end of commutator') unless @scanner.getch == ']'
  end
  
  def parse
    skip_spaces
    parse_open_bracket
    setup_or_first_part = parse_moves
    skip_spaces
    char = @scanner.getch
    comm = if char == ':' || char == ';'
             skip_spaces
             parse_open_bracket
             first_part = parse_moves
             skip_spaces
             complain('middle of pure commutator') unless @scanner.getch == ','
             second_part = parse_moves
             skip_spaces
             parse_close_bracket
             SetupCommutator.new(setup_or_first_part, PureCommutator.new(first_part, second_part))
           elsif char == ','
             second_part = parse_moves
             PureCommutator.new(setup_or_first_part, second_part)
           else
             complain('end of setup or middle of pure commutator') unless @scanner.eos?
           end
    skip_spaces
    parse_close_bracket
    skip_spaces
    complain('end of commutator') unless @scanner.eos?
    comm
  end
    

  def parse_move
    move = @scanner.scan(Move::REGEXP)
    return nil unless move
    Move.new(move)
  end

  def skip_spaces
    @scanner.skip(/\s+/)
  end
end
    
def parse_commutator(alg_string)
  CommutatorParser.new(alg_string).parse
end
