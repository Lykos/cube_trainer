require 'cube_trainer/letter_scheme'
require 'cube_trainer/letter_pair'
require 'cube_trainer/color_scheme'

module CubeTrainer

  class CommutatorReverseEngineer
    
    def initialize(part_type, buffer, letter_scheme, color_scheme, cube_size)
      raise ArgumentError unless part_type.is_a?(Class)
      raise ArgumentError unless buffer.is_a?(Part) && buffer.is_a?(part_type)
      raise ArgumentError unless letter_scheme.is_a?(LetterScheme)
      raise ArgumentError unless color_scheme.is_a?(ColorScheme)
      raise ArgumentError unless cube_size.is_a?(Integer)
      @part_type = part_type
      @buffer = buffer
      @letter_scheme = letter_scheme
      @color_scheme = color_scheme
      @state = color_scheme.solved_cube_state(cube_size)
      @buffer_coordinates = @state.solved_positions(@buffer, 0)
    end

    def piece_at_coordinates(coordinates)
      coordinates
      colors = coordinates.map { |c| @state[c] }
      @color_scheme.part_for_colors(@part_type, colors)
    end

    def find_stuff
      piece0 = piece_at_coordinates(@buffer_coordinates)
      return nil if piece0 == @buffer
      solved_coordinates_of_piece0 = @state.solved_positions(piece0, 0)
      piece1 = piece_at_coordinates(solved_coordinates_of_piece0)
      return nil if piece1 == @buffer
      solved_coordinates_of_piece1 = @state.solved_positions(piece1, 0)
      piece2 = piece_at_coordinates(solved_coordinates_of_piece1)
      if piece2 == @buffer
        LetterPair.new([piece0, piece1].map { |p| @letter_scheme.letter(p) })
      else
        nil
      end
    end

    def find_letter_pair(alg)
      raise ArgumentError unless alg.is_a?(Algorithm)
      alg.inverse.apply_temporarily_to(@state) { find_stuff }
    end

  end

end
