require 'cube'
require 'array_helper'
require 'coordinate'
require 'cube_print_helper'

module CubeTrainer

  class CubeState
    include ArrayHelper
    include CubePrintHelper
    SIDES = COLORS.length
    
    def initialize(n, stickers)
      raise 'Cubes of size smaller than 2 are not supported.' if n < 2
      raise "Cubes must have #{SIDES} sides." unless stickers.length == SIDES
      raise "All sides of a #{n}x#{n} must be #{n}x#{n}." unless stickers.all? { |p| p.length == n && p.all? { |q| q.length == n } }
      raise 'All stickers on the cube must have a valid color.' unless stickers.all? { |p| p.all? { |q| q.all? { |c| COLORS.include?(c) } } }
      @n = n
      @stickers = stickers
    end
  
    attr_reader :n, :stickers
    
    def encode_with(coder)
      coder['stickers'] = @stickers
      coder['n'] = @n
    end
  
    def eql?(other)
      self.class.equal?(other.class) && @stickers == other.stickers && @n == other.n
    end
  
    alias == eql?
  
    def hash
      [@stickers, @n].hash
    end
  
    def self.solved(n)
      stickers = COLORS.collect do |c|
        (0...n).collect { [c] * n }
      end
      CubeState.new(n, stickers)
    end
          
    # The indices of stickers that this piece occupies on the solved cube.
    def solved_positions(piece, incarnation_index)
      coordinate = piece.solved_coordinate(@n, incarnation_index)
      # Try to jump to each neighbor face.
      neighbor_coordinates = coordinate.face.neighbors.collect do |neighbor_face|
        if coordinate.can_jump_to?(neighbor_face)
          coordinate.jump_to_neighbor(neighbor_face)
        else
          # It's important that we put a nil because it shows us how we need to rotate the data in the end.
          nil
        end
      end
      [coordinate] + rotate_out_nils(neighbor_coordinates)
    end
  
    def sticker_array(face)
      @stickers[face.piece_index]
    end
  
    def to_s
      cube_string(self, :nocolor)
    end
  
    def find_cycles(pieces, incarnation_index)
      piece_positions = []
      pieces.each do |p|
        piece_positions.push(solved_positions(p, incarnation_index))
      end
      piece_positions[0].zip(*piece_positions[1..-1])
    end
  
    # Cycles the given positions. Note that it does NOT search for the given pieces and cycle them, rather, it cycles
    # the pieces that are at the position that those pieces would take in a solved state.
    def apply_piece_cycle(pieces, incarnation_index=0)
      raise 'Cycles of length smaller than 2 are not supported.' if pieces.length < 2
      raise 'Cycles of weird piece types are not supported.' unless pieces.all? { |p| p.is_a?(Part) }
      raise "Cycles of heterogenous piece types #{pieces.inspect} are not supported." if pieces.any? { |p| p.class != pieces.first.class }
      raise 'Cycles of invalid pieces are not supported.' unless pieces.all? { |p| p.valid? }
      raise "Invalid incarnation index #{incarnation_index}." unless incarnation_index.is_a?(Integer) && incarnation_index >= 0
      raise "Incarnation index #{incarnation_index} for cube size #{@n} is not supported for #{pieces.first.inspect}." unless incarnation_index < pieces.first.num_incarnations(@n)
      pieces.each_with_index do |p, i|
        pieces.each_with_index do |q, j|
          if i != j && p.turned_equals?(q)
            raise "Pieces #{p} and #{q} are equal modulo rotation, so they can't be cycled."
          end
        end
      end
      cycles = find_cycles(pieces, incarnation_index)
      cycles.each { |c| apply_index_cycle(c) }
    end
  
    def [](coordinate)
      sticker_array(coordinate.face)[coordinate.x][coordinate.y]
    end
  
    def []=(coordinate, color)
      raise "All stickers on the cube must have a valid color." unless COLORS.include?(color)
      sticker_array(coordinate.face)[coordinate.x][coordinate.y] = color
    end
  
    def apply_index_cycle(cycle)
      last_sticker = self[cycle[-1]]
      (cycle.length - 1).downto(1) do |i|
        self[cycle[i]] = self[cycle[i - 1]]
      end
      self[cycle[0]] = last_sticker
    end
  
    def apply_4sticker_cycle(cycle, direction)
      raise ArgumentError unless cycle.length == 4
      if direction.is_double_move?
        apply_index_cycle([cycle[0], cycle[2]])
        apply_index_cycle([cycle[1], cycle[3]])
      else
        # Note that we cannot do reverse! because the values are cached.
        actual_cycle = if direction.value == 3 then cycle.reverse else cycle end
        apply_index_cycle(actual_cycle)
      end
    end
  
    def rotate_slice(face, slice, direction)
      Coordinate.on_slice(face, slice, @n).each do |cycle|
        apply_4sticker_cycle(cycle, direction)
      end
    end
  
    # Rotates the stickers on one face (not a real move, only stickers on one face!)
    def rotate_face(face, direction)
      neighbors = face.neighbors
      inverse_order_face = face.coordinate_index_close_to(neighbors[0]) < face.coordinate_index_close_to(neighbors[1])
      direction = direction.invert if inverse_order_face
      Coordinate.on_face(face, @n).each do |cycle|
        apply_4sticker_cycle(cycle, direction)
      end
    end
  
    def apply_move(move)
      move.apply_to(self)
    end
  end

end
