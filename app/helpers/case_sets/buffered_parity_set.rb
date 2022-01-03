# frozen_string_literal: true

require 'twisty_puzzles'

module CaseSets
  # An alg set with all parities of a given fixed buffer and parity part type.
  class BufferedParitySet < ConcreteCaseSet
    def initialize(buffer_part_type, parity_part_type, buffer)
      super()
      @pattern = case_pattern(
        part_cycle_pattern(
          buffer_part_type, specific_part(buffer), wildcard,
        ),
        part_cycle_pattern(parity_part_type, wildcard, wildcard),
      )
      @buffer_part_type = buffer_part_type
      @parity_part_type = parity_part_type
      @buffer = buffer
    end

    attr_reader :buffer_part_type, :parity_part_type, :buffer, :pattern

    def to_s
      "#{simple_class_name(@buffer_part_type).downcase} #{simple_class_name(@parity_part_type).downcase} parities for buffer #{@buffer}"
    end

    def row_pattern(refinement_index, casee)
      raise ArgumentError if refinement_index != 0 && refinement_index != 1
      raise ArgumentError unless casee.part_cycles.length == 2
      raise ArgumentError unless casee.part_cycles.all? { |c| (c.part_type == @buffer_part_type || c.part_type == @parity_part_type) && c.length == 2 }
      raise ArgumentError if casee.part_cycles.first.part_type == casee.part_cycles.last.part_type

      # We only refine in one direction, in the other direction we just allow a wildcard for
      # the swap that it does for the parity part
      return @pattern if refinement_index == 1

      cycle = casee.part_cycles.find { |c| c.part_type == @buffer_part_type }
      raise ArgumentError unless cycle.any? { |p| p.turned_equal?(@buffer) }

      other_part = cycle.find { |p| !p.turned_equal?(@buffer) }
      raise ArgumentError unless other_part

      part_patterns = [specific_part(@buffer), specific_part(other_part)]
      case_pattern(part_cycle_pattern(@part_type, *part_patterns))
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

      cycle = casee.part_cycles.find { |c| c.part_type == @buffer_part_type }
      raise ArgumentError unless buffer_cycle

      cycle.parts.include?(buffer)
    end

    def create_strict_matching(casee)
      raise ArgumentError unless match?(casee)

      buffer_cycle = casee.part_cycles.find { |c| c.part_type == @buffer_part_type }
      parity_cycle = casee.part_cycles.find { |c| c.part_type == @parity_part_type }
      raise ArgumentError unless buffer_cycle && parity_cycle

      Case.new(part_cycles: [buffer_cycle.start_with(@buffer), parity_cycle])
    end

    def case_name(casee, letter_scheme: nil)
      raise ArgumentError unless match?(casee)

      buffer_cycle = casee.part_cycles.find { |c| c.part_type == @buffer_part_type }
      parity_cycle = casee.part_cycles.find { |c| c.part_type == @parity_part_type }
      raise ArgumentError unless buffer_cycle && parity_cycle

      parts = [buffer_cycle.parts[1]] + parity_cycle
      name_parts = letter_scheme ? parts.map { |p| letter_scheme.letter(p) } : parts
      "#{name_parts[0]} (#{name_parts[1]} ⟷ #{name_parts[2]})"
    end

    def default_cube_size
      @part_type.min_cube_size
    end

    # Returns parity parts adjacent to the buffer.
    def default_parity_parts
      candidates = @parity_part_type::ELEMENTS.select { |c| c.face_symbols.first == @buffer.face_symbols.first }
      max_intersection = candidates.map { |c| (c.face_symbols & @buffer.face_symbols).length }.max
      best_candidates = candidates.select { |c| (c.face_symbols & @buffer.face_symbols).length == max_intersection }
      best_candidates[0..1]
    end

    def cases
      other_parts = @buffer_part_type::ELEMENTS.select { |a| !a.turned_equals?(@buffer) }
      other_parts.map do |p|
        Case.new(
          part_cycles: [
            TwistyPuzzles::PartCycle.new([@buffer, p]),
            TwistyPuzzles::PartCycle.new(default_parity_parts)
          ]
        )
      end
    end

    private

    def refined_part(refinement_index, casee)
      casee.part_cycles.first.start_with(@buffer).parts[refinement_index + 1]
    end
  end
end
