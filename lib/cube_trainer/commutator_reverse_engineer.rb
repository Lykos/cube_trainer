# frozen_string_literal: true

require 'cube_trainer/core/coordinate'
require 'cube_trainer/core/cube'
require 'cube_trainer/core/cube_state'
require 'cube_trainer/letter_scheme'
require 'cube_trainer/letter_pair'
require 'cube_trainer/color_scheme'

module CubeTrainer
  # Class that figures out what cycle a given commutator alg performs.
  class CommutatorReverseEngineer
    def initialize(part_type, buffer, letter_scheme, cube_size)
      raise TypeError unless part_type.is_a?(Class)
      raise TypeError unless buffer.is_a?(Core::Part) && buffer.is_a?(part_type)
      raise TypeError unless letter_scheme.is_a?(LetterScheme)
      raise TypeError unless cube_size.is_a?(Integer)

      @part_type = part_type
      @buffer = buffer
      @letter_scheme = letter_scheme
      @solved_positions = {}
      @state = initial_cube_state(part_type, cube_size)
      @buffer_coordinate = solved_position(@buffer, cube_size)
    end

    def initial_cube_state(part_type, cube_size)
      # We don't care much about any other pieces, so we'll just use nil
      # everywhere.
      cube_state = Core::CubeState.from_stickers(cube_size, nil_stickers(cube_size))
      # We write on every sticker where it was in the initial state.
      # That way we can easily reverse engineer what a commutator does.
      part_type::ELEMENTS.each do |part|
        cube_state[solved_position(part, cube_size)] = part
      end
      cube_state
    end

    def nil_stickers(cube_size)
      Core::Face::ELEMENTS.map do
        Array.new(cube_size) do
          Array.new(cube_size) do
            nil
          end
        end
      end
    end

    def solved_position(part, cube_size)
      @solved_positions[part] ||= Core::Coordinate.solved_position(part, cube_size, 0)
    end

    def find_stuff(state)
      part0 = state[@buffer_coordinate]
      return if part0 == @buffer

      part1 = state[solved_position(part0, @state.n)]
      return if part1 == @buffer

      part2 = state[solved_position(part1, @state.n)]
      LetterPair.new([part0, part1].map { |p| @letter_scheme.letter(p) }) if part2 == @buffer
    end

    def find_letter_pair(alg)
      raise TypeError unless alg.is_a?(Core::Algorithm)

      alg.inverse.apply_temporarily_to(@state) { |s| find_stuff(s) }
    end
  end
end
