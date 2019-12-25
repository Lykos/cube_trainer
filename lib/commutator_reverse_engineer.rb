module CubeTrainer

  class CommutatorReverseEngineer
    def initialize(part_type, buffer, letter_scheme, cube_size)
      @part_type = part_type
      @buffer = buffer
      @letter_scheme = letter_scheme
      @state = CubeState.solved(cube_size)
      @buffer_coordinates = @state.solved_positions(@buffer, 0)
    end

    def piece_at_coordinates(coordinates)
      p coordinates
      p colors = coordinates.map { |c| @state[c] }
      p @part_type.for_colors(colors)
    end

    def find_stuff
      puts "Find stuff"
      p piece0 = piece_at_coordinates(@buffer_coordinates)
      p solved_coordinates_of_piece0 = @state.solved_positions(piece0, 0)
      p piece1 = piece_at_coordinates(solved_coordinates_of_piece0)
      p solved_coordinates_of_piece1 = @state.solved_positions(piece1, 0)
      p piece2 = piece_at_coordinates(solved_coordinates_of_piece1)
      if piece2 == @buffer
        LetterPair.new([piece0, piece1].map { |p| @letter_scheme.letter(p) })
      else
        nil
      end
    end

    def find_letter_pair(alg)
      @state.apply_algorithm(alg.inverse)
      result = find_stuff
      @state.apply_algorithm(alg)
      result
    end
  end

end
