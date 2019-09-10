require 'strscan'
require 'cube'
require 'move'

module CubeTrainer

  class CommutatorParseError < StandardError
  end

  class Commutator
    def cancellations(other, metric=:htm)
      algorithm.cancellations(other.algorithm, metric)
    end
  end

  # Algorithm that is used like a commutator but actually isn't one.
  class FakeCommutator < Commutator
    def initialize(algorithm)
      raise ArgumentError unless algorithm.is_a?(Algorithm)
      @algorithm = algorithm
    end

    attr_reader :algorithm

    def eql?(other)
      self.class.equal?(other.class) && @algorithm == other.algorithm
    end

    alias == eql?

    def hash
      @algorithm.hash
    end

    def inverse
      FakeCommutator.new(@algorithm.invert)
    end

    def to_s
      @algorithm.to_s
    end
  end
  
  class PureCommutator < Commutator
    def initialize(first_part, second_part)
      raise ArgumentError unless first_part.is_a?(Algorithm)
      raise ArgumentError unless second_part.is_a?(Algorithm)
      @first_part = first_part
      @second_part = second_part
    end
  
    attr_reader :first_part, :second_part
  
    def eql?(other)
      self.class.equal?(other.class) && @first_part == other.first_part && @second_part == other.second_part
    end
  
    alias == eql?
  
    def hash
      [@first_part, @second_part].hash
    end
    
    def inverse
      PureCommutator.new(second_part, first_part)
    end
  
    def to_s
      "[#{@first_part}, #{@second_part}]"
    end

    def algorithm
      first_part + second_part + first_part.invert + second_part.invert
    end
  end
  
  class SetupCommutator < Commutator
    def initialize(setup, inner_commutator)
      raise ArgumentError, "Setup move has to be an algorithm." unless setup.is_a?(Algorithm)
      raise ArgumentError, "Inner commutator has to be a commutator." unless inner_commutator.is_a?(Commutator)
      @setup = setup
      @inner_commutator = inner_commutator
    end
  
    attr_reader :setup, :inner_commutator
  
    def eql?(other)
      self.class.equal?(other.class) && @setup == other.setup && @inner_commutator == other.inner_commutator
    end
  
    alias == eql?
  
    def hash
      [@setup, @inner_commutator].hash
    end
  
    def inverse
      SetupCommutator.new(setup, @inner_commutator.inverse)
    end
  
    def to_s
      "[#{@setup} : #{@inner_commutator}]"
    end

    def algorithm
      setup + inner_commutator.algorithm + setup.invert
    end
  end
  
  class CommutatorParser 
    def initialize(alg_string)
      @alg_string = alg_string
      @scanner = StringScanner.new(alg_string)
    end

    OPENING_PAREN = '('
    CLOSING_PAREN = ')'
    TIMES = '*'
  
    def parse_open_paren
      complain('beginning of trigger') unless @scanner.getch == OPENING_PAREN
    end
    
    def parse_close_paren
      complain('end of trigger') unless @scanner.getch == CLOSING_PAREN
    end

    def parse_times
      complain('times symbol of multiplier') unless @scanner.getch == TIMES
    end

    def parse_factor
      number = @scanner.scan(/\d+/)
      complain('factor of multiplier') unless number
      number.to_i
    end

    def parse_multiplier
      skip_spaces
      parse_times
      skip_spaces
      parse_factor
    end

    def parse_trigger
      parse_open_paren
      skip_spaces
      moves = parse_moves_with_triggers
      skip_spaces
      parse_close_paren
      skip_spaces
      if @scanner.peek(1) == TIMES
        factor = parse_multiplier
        moves * factor
      elsif ('0'..'9').include?(@scanner.peek(1))
        factor = parse_factor
        moves * factor
      else
        moves
      end
    end
  
    # Parses at least one move and allows for triggers in parentheses.
    def parse_moves_with_triggers
      skip_spaces
      if @scanner.peek(1) == OPENING_PAREN
        parse_trigger + parse_moves_with_triggers
      else
        parse_moves
      end
    end

    # Parses at least one move.
    def parse_nonempty_moves
      moves = parse_moves
      complain('move') if moves.empty?
      moves
    end

    # Parses a series of moves.
    def parse_moves
      moves = []
      while m = begin skip_spaces; parse_move_internal end
        moves.push(m)
      end
      Algorithm.new(moves)
    end
  
    def complain(parsed_object)
      raise CommutatorParseError, "Couldn't parse #{parsed_object} here:\n#{@alg_string}\n#{' ' * @scanner.pos}^" 
    end

    OPENING_BRACKET = '['
    CLOSING_BRACKET = ']'
  
    def parse_open_bracket
      complain('beginning of commutator') unless @scanner.getch == OPENING_BRACKET
    end
    
    def parse_close_bracket
      complain('end of commutator') unless @scanner.getch == CLOSING_BRACKET
    end

    def parse
      skip_spaces
      if @scanner.peek(1) == OPENING_BRACKET
        parse_commutator_internal
      else
        FakeCommutator.new(parse_moves_with_triggers)
      end
    end

    def parse_setup_commutator_inner
      skip_spaces
      if @scanner.peek(1) == OPENING_BRACKET
        parse_pure_commutator
      else
        FakeCommutator.new(parse_moves_with_triggers)
      end
    end

    def parse_pure_commutator
      skip_spaces
      parse_open_bracket
      first_part = parse_nonempty_moves
      skip_spaces
      complain('middle of pure commutator') unless @scanner.getch == ','
      second_part = parse_nonempty_moves
      skip_spaces
      parse_close_bracket
      PureCommutator.new(first_part, second_part)
    end
    
    def parse_commutator_internal
      skip_spaces
      parse_open_bracket
      setup_or_first_part = parse_nonempty_moves
      skip_spaces
      char = @scanner.getch
      comm = if char == ':' || char == ';'
               inner_commutator = parse_setup_commutator_inner
               SetupCommutator.new(setup_or_first_part, inner_commutator)
             elsif char == ','
               second_part = parse_nonempty_moves
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
      
  
    def parse_move_internal
      move = @scanner.scan(MOVE_REGEXP)
      return nil unless move
      parse_move(move)
    end
  
    def skip_spaces
      @scanner.skip(/\s+/)
    end
  end
      
  def parse_commutator(alg_string)
    CommutatorParser.new(alg_string).parse
  end

end
