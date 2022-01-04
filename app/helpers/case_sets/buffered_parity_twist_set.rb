# frozen_string_literal: true

require 'twisty_puzzles'

module CaseSets
  # An alg set with all parities of a given fixed buffer and parity part type.
  class BufferedParityTwistSet < ConcreteCaseSet
    def initialize(buffer_part_type, parity_part_type, buffer)
      super()
      @pattern = case_pattern(
        part_cycle_pattern(
          buffer_part_type, specific_part(buffer), wildcard, twist: any_unsolved_twist
        ),
        part_cycle_pattern(
          buffer_part_type, wildcard, twist: any_unsolved_twist
        ),
        part_cycle_pattern(parity_part_type, wildcard, wildcard),
      )
      @buffer_part_type = buffer_part_type
      @parity_part_type = parity_part_type
      @buffer = buffer
    end

    attr_reader :buffer_part_type, :parity_part_type, :buffer, :pattern

    def to_s
      "#{simple_class_name(@buffer_part_type).downcase} #{simple_class_name(@parity_part_type).downcase} parity twists for buffer #{@buffer}"
    end

    def row_pattern(refinement_index, casee)
      raise ArgumentError if refinement_index != 0 && refinement_index != 1
      raise ArgumentError unless casee.part_cycles.length == 3
      raise ArgumentError unless casee.part_cycles.all? { |c| (c.part_type == @buffer_part_type || c.part_type == @parity_part_type) && c.length == 2 }

      # We only refine in one direction, in the other direction we just allow a wildcard for
      # the swap that it does for the parity part
      return @pattern if refinement_index == 1

      cycle = casee.part_cycles.find { |c| c.length == 2 && c.part_type == @buffer_part_type }
      raise ArgumentError unless cycle.any? { |p| p.turned_equal?(@buffer) }

      other_part = cycle.find { |p| !p.turned_equal?(@buffer) }
      raise ArgumentError unless other_part

      part_patterns = [specific_part(@buffer), specific_part(other_part)]
      case_pattern(
        part_cycle_pattern(@part_type, *part_patterns, twist: any_unsolved_twist),
        part_cycle_pattern(
          buffer_part_type, wildcard, twist: any_unsolved_twist
        ),
        part_cycle_pattern(parity_part_type, wildcard, wildcard)
      )
    end

    def self.from_raw_data_parts(raw_data)
      unless raw_data.length == 3
        raise ArgumentError,
              "expected 3 parts, got #{raw_data.join(', ')}"
      end

      buffer_part_type = TwistyPuzzles::PART_TYPES.find { |t| simple_class_name(t) == raw_data[0] }
      raise ArgumentError unless buffer_part_type

      parity_part_type = TwistyPuzzles::PART_TYPES.find { |t| simple_class_name(t) == raw_data[1] }
      raise ArgumentError unless parity_part_type

      buffer = buffer_part_type.parse(raw_data[2])
      new(buffer_part_type, parity_part_type, buffer)
    end

    def to_raw_data_parts_internal
      [simple_class_name(@buffer_part_type), simple_class_name(@parity_part_type), @buffer.to_s]
    end

    def strict_match?(casee)
      return false unless match?(casee)

      cycle = buffer_cycle(casee)
      raise ArgumentError unless cycle

      cycle.parts.include?(buffer)
    end

    def create_strict_matching(casee)
      raise ArgumentError unless match?(casee)

      buffer_cyclee = buffer_cycle(casee)
      twist_cyclee = twist_cycle(casee)
      parity_cyclee = parity_cycle(casee)
      raise ArgumentError unless buffer_cyclee && twist_cyclee && parity_cyclee

      Case.new(part_cycles: [buffer_cyclee.start_with(@buffer), twist_cyclee, parity_cyclee])
    end

    def case_name(casee, letter_scheme: nil)
      raise ArgumentError unless match?(casee)
      raise ArgumentError unless buffer_cycle && twist_cycle && parity_cycle

      parts = [buffer_cycle.parts[1]] + parity_cycle.parts + twist_cycle.parts
      name_parts = letter_scheme ? parts.map { |p| letter_scheme.letter(p) } : parts
      "#{name_parts[0]} (#{name_parts[1]} ⟷ #{name_parts[2]}, #{name_parts[3]})"
    end

    def default_cube_size
      candidate = [@buffer_part_type.min_cube_size, @parity_part_type.min_cube_size].max
      if @buffer_part_type.exists_on_cube_size?(candidate) && @parity_part_type.exists_on_cube_size?(candidate)
        return candidate
      end
      candidate += 1
      if @buffer_part_type.exists_on_cube_size?(candidate) && @parity_part_type.exists_on_cube_size?(candidate)
        return candidate
      end
      raise
    end

    # Returns parity parts adjacent to the buffer.
    def default_parity_parts
      candidates = @parity_part_type::ELEMENTS.select { |c| c.face_symbols.first == @buffer.face_symbols.first }
      max_intersection = candidates.map { |c| (c.face_symbols & @buffer.face_symbols).length }.max
      best_candidates = candidates.select { |c| (c.face_symbols & @buffer.face_symbols).length == max_intersection }
      best_candidates[0..1]
    end

    def cases
      part_permutations = @part_type::ELEMENTS.permutation(2).select { |a, b| !a.turned_equals?(b) && !a.turned_equals?(buffer) && !b.turned_equals?(buffer) }
      part_permutations.flat_map do |swap_part, twist_part|
        twists.map do |twist|
          Case.new(
            part_cycles: [
              TwistyPuzzles::PartCycle.new([@buffer, swap_part], inverse_twist(twist)),
              TwistyPuzzles::PartCycle.new([swap_part], twist),
              TwistyPuzzles::PartCycle.new(default_parity_parts)
            ]
          )
        end
      end
    end

    private

    def buffer_cycle(casee)
      casee.part_cycles.find { |c| c.length == 2 && c.part_type == @buffer_part_type }
    end

    def twist_cycle(casee)
      casee.part_cycles.find { |c| c.length == 1 && c.part_type == @buffer_part_type }
    end

    def parity_cycle(casee)
      casee.part_cycles.find { |c| c.length == 2 && c.part_type == @parity_part_type }
    end

    def twists
      (1...@part_type::ELEMENTS.first.rotations.length)
    end

    def inverse_twist(twist)
      @part_type::ELEMENTS.first.rotations.length - twist
    end

    def refined_part(refinement_index, casee)
      casee.part_cycles.first.start_with(@buffer).parts[refinement_index + 1]
    end
  end
end
