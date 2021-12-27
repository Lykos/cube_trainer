# frozen_string_literal: true

require 'cube_trainer/letter_pair'
require 'twisty_puzzles'
require 'twisty_puzzles/utils'

module CubeTrainer
  # Class that figures out what cycle a given commutator alg performs.
  class CommutatorReverseEngineer
    include TwistyPuzzles::Utils::ArrayHelper

    # TODO: Also look at different cube sizes.
    def initialize(cube_size:, part_type: nil, buffer: nil)
      raise TypeError unless part_type.nil? || part_type.is_a?(Class)
      raise TypeError unless buffer.nil? || buffer_satisfies_part_type?(buffer, part_type)
      raise TypeError unless cube_size.is_a?(Integer)

      @cube_size = cube_size
      @part_type = part_type
      @buffer = buffer
      @solved_positions = {}
      @state = initial_cube_state
    end

    def buffer_satisfies_part_type?(buffer, part_type)
      buffer.is_a?(TwistyPuzzles::Part) && (part_type.nil? || buffer.is_a?(part_type))
    end

    def initial_cube_state
      # We don't care much about any other pieces, so we'll just use nil
      # everywhere.
      cube_state = TwistyPuzzles::CubeState.from_stickers(@cube_size, nil_stickers)
      # We write on every sticker where it was in the initial state.
      # That way we can easily reverse engineer what a commutator does.
      relevant_parts.each do |part|
        cube_state[solved_position(part)] = part
      end
      cube_state
    end

    def nil_stickers
      TwistyPuzzles::Face::ELEMENTS.map do
        Array.new(@cube_size) do
          Array.new(@cube_size) do
            nil
          end
        end
      end
    end

    def relevant_part_types
      @relevant_part_types ||=
        @part_type ? [@part_type] : TwistyPuzzles::PART_TYPES - [TwistyPuzzles::Face]
    end

    def relevant_parts
      relevant_part_types.filter_map do |part_type|
        next unless part_type.exists_on_cube_size?(@cube_size)

        part_type::ELEMENTS
      end.flatten
    end

    def solved_position(part)
      @solved_positions[part] ||= TwistyPuzzles::Coordinate.solved_position(part, @cube_size, 0)
    end

    def find_part_cycle_internal(state, buffer)
      # We make use of the fact that the stickers of our cube are actually the parts themselves.
      current_part = state[solved_position(buffer)]
      parts = [buffer]
      until current_part.turned_equals?(buffer)
        parts.push(current_part)
        current_part = state[solved_position(current_part)]
      end
      twist = current_part.rotations.index(buffer)
      TwistyPuzzles::PartCycle.new(parts, twist)
    end

    def find_part_cycles_internal(state)
      remaining_parts = relevant_parts
      cycles = []

      until remaining_parts.empty?
        buffer = remaining_parts.pop
        cycle = find_part_cycle_internal(state, buffer)
        remaining_parts.delete_if { |p| cycle.parts.any? { |q| p.turned_equals?(q) } }
        cycles.push(cycle) if cycle.length > 1 || cycle.twist.positive?
      end

      cycles
    end

    def find_part_cycles(alg)
      raise TypeError unless alg.is_a?(TwistyPuzzles::Algorithm)

      alg.inverse.apply_temporarily_to(@state) { |s| find_part_cycles_internal(s) }
    end

    def find_part_cycle(alg)
      raise TypeError unless alg.is_a?(TwistyPuzzles::Algorithm)
      raise ArgumentError unless @buffer

      alg.inverse.apply_temporarily_to(@state) { |s| find_part_cycle_internal(s, @buffer) }
    end
  end
end
