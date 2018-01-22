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
  
    def face_lines(face, reverse_lines, reverse_columns)
      stickers_to_lines(@stickers[face.piece_index], reverse_lines, reverse_columns)
    end
  
    def to_s
      # TODO Push more functionality into CubePrintHelper in order to not pollute this class
      yellow_face = face_lines(Face.for_color(:yellow), true, true)
      blue_face = face_lines(Face.for_color(:blue), false, true)
      red_face = face_lines(Face.for_color(:red), false, true)
      green_face = face_lines(Face.for_color(:green), false, false)
      orange_face = face_lines(Face.for_color(:orange), false, false)
      white_face = face_lines(Face.for_color(:white), false, true)
      middle_belt = zip_concat_lines(blue_face, red_face, green_face, orange_face)
      lines = pad_lines(yellow_face, @n) + middle_belt + pad_lines(white_face, @n)
      lines.join("\n")
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
      raise 'Cycles of heterogenous piece types are not supported.' if pieces.any? { |p| p.class != pieces.first.class }
      raise 'Cycles of weird piece types are not supported.' unless pieces.all? { |p| p.is_a?(Part) }
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
      @stickers[coordinate.face.piece_index][coordinate.x][coordinate.y]
    end
  
    def []=(coordinate, color)
      raise "All stickers on the cube must have a valid color." unless COLORS.include?(color)
      @stickers[coordinate.face.piece_index][coordinate.x][coordinate.y] = color
    end
  
    def apply_index_cycle(cycle)
      last_sticker = self[cycle[-1]]
      (cycle.length - 1).downto(1) do |i|
        self[cycle[i]] = self[cycle[i - 1]]
      end
      self[cycle[0]] = last_sticker
    end
  
    def apply_4sticker_cycle(cycle, direction)
      raise unless cycle.length == 4
      if direction == 2
        apply_index_cycle([cycle[0], cycle[2]])
        apply_index_cycle([cycle[1], cycle[3]])
      else
        cycle.reverse! if direction == 3
        apply_index_cycle(cycle)
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
      direction = 4 - direction if inverse_order_face
      Coordinate.on_face(face, @n).each do |cycle|
        apply_4sticker_cycle(cycle, direction)
      end
    end
  
    def apply_move(move)
      move.apply_to(self)
    end
  end

end
