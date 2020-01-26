require 'cube_trainer/letter_scheme'
require 'cube_trainer/letter_pair'
require 'cube_trainer/color_scheme'

module CubeTrainer

  class CommutatorReverseEngineer
    
    def initialize(part_type, buffer, letter_scheme, cube_size)
      raise TypeError unless part_type.is_a?(Class)
      raise TypeError unless buffer.is_a?(Part) && buffer.is_a?(part_type)
      raise TypeError unless letter_scheme.is_a?(LetterScheme)
      raise TypeError unless cube_size.is_a?(Integer)
      @part_type = part_type
      @buffer = buffer
      @letter_scheme = letter_scheme
      # We don't care much about any other pieces, so we'll just use nil
      # everywhere.
      stickers = Face::ELEMENTS.map do |face_symbol|
        (0...cube_size).map do |x|
          (0...cube_size).map do |y|
            nil
          end
        end
      end
      @state = CubeState.from_stickers(cube_size, stickers)
      @solved_positions = {}
      @buffer_coordinate = solved_position(@buffer)
      # We write on every sticker where it was in the initial state.
      # That way we can easily reverse engineer what a commutator does.
      part_type::ELEMENTS.each do |part|
        @state[solved_position(part)] = part
      end
    end

    def solved_position(part)
      @solved_positions[part] ||= Coordinate.solved_position(part, @state.n, 0)
    end

    def find_stuff
      part0 = @state[@buffer_coordinate]
      return nil if part0 == @buffer
      part1 = @state[solved_position(part0)]
      return nil if part1 == @buffer
      part2 = @state[solved_position(part1)]
      if part2 == @buffer
        LetterPair.new([part0, part1].map { |p| @letter_scheme.letter(p) })
      else
        nil
      end
    end

    def find_letter_pair(alg)
      raise TypeError unless alg.is_a?(Algorithm)
      alg.inverse.apply_temporarily_to(@state) { find_stuff }
    end

  end

end
