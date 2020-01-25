require 'cube_trainer/cube'
require 'cube_trainer/cube_constants'
require 'cube_trainer/array_helper'
require 'cube_trainer/coordinate'
require 'cube_trainer/cube_print_helper'
require 'cube_trainer/state_helper'
require 'cube_trainer/native'

module CubeTrainer

  class CubeState
    include ArrayHelper
    include CubePrintHelper
    include StateHelper
    include CubeConstants

    def self.check_cube_size(n)
      raise TypeError unless n.is_a?(Integer)
      raise ArgumentError, 'Cubes of size smaller than 2 are not supported.' if n < 2
    end
    
    def initialize(n, stickers)
      CubeState.check_cube_size(n)
      raise ArgumentError, "Cubes must have #{FACES} sides." unless stickers.length == FACES
      raise ArgumentError, "All sides of a #{n}x#{n} must be #{n}x#{n}." unless stickers.all? { |p| p.length == n && p.all? { |q| q.length == n } }
      @n = n
      @stickers = stickers
      @native_cube_state = Native::CubeState.new(n, stickers)
    end

    def dup
      CubeState.new(@n, @stickers.map { |p| p.map { |q| q.dup } })
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
  
    def rotate_piece(piece, incarnation_index=0)
      apply_sticker_cycle(solved_positions(piece, 0))
    end

    # The indices of stickers that this piece occupies on the solved cube.
    def solved_positions(piece, incarnation_index=0)
      coordinate = piece.solved_coordinate(@n, incarnation_index)
      piece_coordinates(coordinate)
    end

    # The indices of the stickers occupied by the piece that occupies the sticker at the given coordinate (note that the piece may additionally occupy other stickers).
    def piece_coordinates(coordinate)
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
      cycles.each { |c| apply_sticker_cycle(c) }
    end
  
    def [](coordinate)
      sticker_array(coordinate.face)[coordinate.x][coordinate.y]
    end
  
    def []=(coordinate, color)
      sticker_array(coordinate.face)[coordinate.x][coordinate.y] = color
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
      direction = direction.inverse if inverse_order_face
      Coordinate.on_face(face, @n).each do |cycle|
        apply_4sticker_cycle(cycle, direction)
      end
    end
  
    def apply_move(move)
      move.apply_to(self)
    end

    def apply_algorithm(alg)
      alg.apply_to(self)
    end

    def apply_rotation(rot)
      rot.apply_to_cube(self)
    end

  end

end
