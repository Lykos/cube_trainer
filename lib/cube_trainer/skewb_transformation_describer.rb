# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles/utils'

module CubeTrainer
  # Helper class to generate a concise human readable description of how a Skewb algorithm
  # moves parts around.
  class SkewbTransformationDescriber
    include TwistyPuzzles::Utils::ArrayHelper

    TOP_BOTTOM_CORNERS =
      DOUBLE_ARROW = ' ↔ '
    ARROW = ' → '

    # Represents a sequence of Skewb parts.
    class PartSequence
      def initialize(letter_scheme, parts)
        unless letter_scheme.nil? || letter_scheme.is_a?(TwistyPuzzles::LetterScheme)
          raise ArgumentError
        end
        raise ArgumentError unless parts.all? { |p| p.is_a?(TwistyPuzzles::Part) }

        @letter_scheme = letter_scheme
        @parts = parts
      end

      attr_reader :parts

      def to_s
        if @letter_scheme
          description_internal(@parts.map { |p| @letter_scheme.letter(p).capitalize })
        else
          description_internal(@parts)
        end
      end

      def description_internal
        raise NotImplementedError
      end

      def reverse
        self.class.new(@letter_scheme, @parts.reverse)
      end

      def trivial?
        @parts.length <= 1 || @parts == [@parts[0], @parts[0]]
      end
    end

    # Represents a move of a Skewb part to the place of another Skewb part.
    class PartMove < PartSequence
      def initialize(letter_scheme, parts)
        raise ArgumentError unless parts.length == 2

        super
      end

      def source
        @parts.first
      end

      def target
        @parts.last
      end

      def description_internal(parts)
        if parts[0] == parts[1]
          "#{parts[0]} stays"
        else
          parts.join(ARROW)
        end
      end

      def <=>(other)
        target <=> other.target
      end
    end

    # Represents a cycle of Skewb parts.
    class PartCycle < PartSequence
      def first_move
        PartMove.new(@letter_scheme, @parts[0..1])
      end

      def simplify(interesting_parts)
        return self if @parts.empty?

        simplified_parts = []
        first_part = parts.first
        parts.each do |part|
          simplified_parts.push(part)
          # Stop after we reach a rotation of the first part
          # (but still include that target to show the rotation or the end of the cycle).
          break if simplified_parts.length > 1 && first_part.rotations.include?(part)
          # Stop when we reach the first uninteresting part
          # (but still include that target to show where the last interesting part moves).
          break if (interesting_parts & part.rotations).empty?
        end
        PartCycle.new(@letter_scheme, simplified_parts)
      end

      def description_internal(parts)
        if parts.length == 3 && parts[0] == parts[2]
          parts[0..1].join(DOUBLE_ARROW)
        elsif parts[0] == parts[-1]
          parts[0..-2].join(ARROW)
        else
          parts.join(ARROW)
        end
      end

      def <=>(other)
        @parts <=> other.parts
      end
    end

    def initialize(
      interesting_faces,
      interesting_corners,
      staying_mode,
      color_scheme,
      letter_scheme = nil
    )
      raise ArgumentError unless %i[show_staying omit_staying].include?(staying_mode)
      raise TypeError unless color_scheme.is_a?(TwistyPuzzles::ColorScheme)
      raise TypeError unless letter_scheme.nil? || letter_scheme.is_a?(TwistyPuzzles::LetterScheme)

      check_types(interesting_faces, TwistyPuzzles::Face)
      check_types(interesting_corners, TwistyPuzzles::Corner)
      @interesting_faces = interesting_faces
      @interesting_corners = interesting_corners
      @show_staying = staying_mode == :show_staying
      @color_scheme = color_scheme
      @skewb_state = @color_scheme.solved_skewb_state
      @letter_scheme = letter_scheme
    end

    def find_complete_source_cycle(state, part)
      complete_cycle = []
      current_part = part
      loop do
        complete_cycle.push(current_part)
        break if complete_cycle.length > 1 && current_part == part

        next_part_colors = current_part.rotations.map { |r| state[yield(r)] }
        current_part = @color_scheme.part_for_colors(part.class, next_part_colors)
      end
      PartCycle.new(@letter_scheme, complete_cycle)
    end

    # Finds permutation cycles of parts.
    def find_part_target_cycles(interesting_parts, state, &make_coordinate)
      used_parts = []
      interesting_parts.map do |part|
        next unless (used_parts & part.rotations).empty?

        cycle = find_complete_source_cycle(state, part, &make_coordinate)
                .simplify(interesting_parts).reverse
        used_parts += cycle.parts
        @show_staying || !cycle.trivial? ? cycle : nil
      end.compact
    end

    # Finds where each part comes from.
    def find_part_sources(interesting_parts, state, &make_coordinate)
      interesting_parts.collect_concat do |part|
        source_cycle = find_complete_source_cycle(state, part, &make_coordinate)
        if @show_staying || !source_cycle.trivial?
          [source_cycle.first_move.reverse]
        else
          []
        end
      end
    end

    # Describes where each interesting piece comes from.
    def source_descriptions(algorithm)
      algorithm.apply_temporarily_to(@skewb_state) do |s|
        find_part_sources(@interesting_corners, s, &TwistyPuzzles::SkewbCoordinate.method(:for_corner)) + # rubocop:disable Layout/LineLength
          find_part_sources(@interesting_faces, s, &TwistyPuzzles::SkewbCoordinate.method(:for_center)) # rubocop:disable Layout/LineLength
      end.sort
    end

    # Describes what kind of tranformation the alg does in terms of piece cycles.
    def transformation_descriptions(algorithm)
      algorithm.apply_temporarily_to(@skewb_state) do |s|
        find_part_target_cycles(@interesting_corners, s, &TwistyPuzzles::SkewbCoordinate.method(:for_corner)) + # rubocop:disable Layout/LineLength
          find_part_target_cycles(@interesting_faces, s, &TwistyPuzzles::SkewbCoordinate.method(:for_center)) # rubocop:disable Layout/LineLength
      end.sort
    end
  end
end
