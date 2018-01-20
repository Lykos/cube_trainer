require 'cube'
require 'array_helper'
require 'coordinate_helper'
require 'cube_print_helper'

module CubeTrainer

  class CubeState
    include ArrayHelper
    include CoordinateHelper
    include CubePrintHelper
    SIDES = COLORS.length
    
    def initialize(n, stickers)
      raise 'Cubes of size smaller than 2 are not supported.' if n < 2
      raise 'Cubes of size bigger than 5 are not supported.' if n > 5
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
  
    def piece_indices(face, x, y)
      puts "piece indices #{face.inspect} (#{x}, #{y})"
      indices = [[face, x, y]]
      coordinates = [x, y]
      # Try to jump to each neighbor face.
      face.neighbors.each do |neighbor_face|
        if can_jump_to?(face, neighbor_face, coordinates)
          indices.push([neighbor_face] + face.jump_to_neighbor(coordinates, neighbor_face))
        end
      end
      p indices
    end
          
    # The indices of stickers that this piece occupies on the solved cube.
    def solved_positions(piece)
      face = Face.for_color(piece.colors.first)
      piece_indices(face, *piece.index_on_face)
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
      lines.join('\n')
    end
  
    def find_cycles(pieces)
      piece_positions = []
      pieces.each do |p|
        piece_positions.push(solved_positions(p))
      end
      piece_positions[0].zip(*piece_positions[1..-1])
    end
  
    # Cycles the given positions. Note that it does NOT search for the given pieces and cycle them, rather, it cycles
    # the pieces that are at the position that those pieces would take in a solved state.
    def apply_piece_cycle(pieces)
      raise 'Cycles of length smaller than 2 are not supported.' if pieces.length < 2
      raise 'Cycles of heterogenous piece types are not supported.' if pieces.any? { |p| p.class != pieces[0].class }
      raise 'Cycles of weird piece types are not supported.' unless pieces.all? { |p| p.is_a?(Part) }
      raise 'Cycles of invalid pieces are not supported.' unless pieces.all? { |p| p.valid? }
      raise 'Cycles of invalid pieces are not supported.' unless pieces.all? { |p| p.valid_for_cube_size?(@n) }
      pieces.each_with_index do |p, i|
        pieces.each_with_index do |q, j|
          if i != j && p.turned_equals?(q)
            raise "Pieces #{p} and #{q} are equal modulo rotation, so they can't be cycled."
          end
        end
      end
      cycles = find_cycles(pieces)
      cycles.each { |c| apply_index_cycle(c) }
    end
  
    def [](face, b, c)
      raise unless face.is_a?(Face)
      raise unless valid_coordinate?(b) && valid_coordinate?(c)
      @stickers[face.piece_index][b][c]
    end
  
    def []=(face, b, c, d)
      raise unless face.is_a?(Face)
      raise unless valid_coordinate?(b) && valid_coordinate?(c)
      raise "All stickers on the cube must have a valid color." unless COLORS.include?(d)
      @stickers[face.piece_index][b][c] = d
    end
  
    def apply_index_cycle(cycle)
      last_sticker = self[*cycle[-1]]
      (cycle.length - 1).downto(1) do |i|
        self[*cycle[i]] = self[*cycle[i - 1]]
      end
      self[*cycle[0]] = last_sticker
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
      neighbors = face.neighbors
      y = face.make_coordinate_relative_to(slice)
      0.upto(highest_coordinate) do |x|
        cycle = neighbors.collect.with_index do |neighbor, i|
          next_neighbor = neighbors[(i + 1) % 4]
          real_x = next_neighbor.make_coordinate_relative_to(x)
          coordinates = [real_x]
          coordinates.insert(neighbor.coordinate_index_close_to(face), y)
          [neighbor] + coordinates
        end
        apply_4sticker_cycle(cycle, direction)
      end
    end
  
    # Rotates the stickers on one face (not a real move, only stickers on one face!)
    def rotate_face(face, direction)
      neighbors = face.neighbors
      inverse_order_face = face.coordinate_index_close_to(neighbors[0]) < face.coordinate_index_close_to(neighbors[1])
      direction = 4 - direction if inverse_order_face
      0.upto(middle_or_after) do |x|
        0.upto(last_before_middle) do |y|
          cycle = coordinate_rotations(x, y).collect { |x, y| [face, x, y] }
          apply_4sticker_cycle(cycle, direction)
        end
      end
    end
  
    def apply_move(move)
      move.apply_to(self)
    end
  end

end
