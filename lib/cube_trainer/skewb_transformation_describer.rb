# frozen_string_literal: true

require 'cube_trainer/core/cube'
require 'cube_trainer/core/skewb_state'
require 'cube_trainer/color_scheme'
require 'cube_trainer/letter_scheme'

module CubeTrainer
  class SkewbTransformationDescriber
    TOP_BOTTOM_CORNERS =
      DOUBLE_ARROW = ' ↔ '
    ARROW = ' → '

    class PartSequence
      def initialize(letter_scheme, parts)
        unless letter_scheme.nil? || letter_scheme.is_a?(LetterScheme)
          raise ArgumentError
        end
        raise ArgumentError unless parts.all? { |p| p.is_a?(Part) }

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
          # Stop after we reach a rotation of the first part (but still include that target to show the rotation or the end of the cycle).
          if simplified_parts.length > 1 && first_part.rotations.include?(part)
            break
          end
          # Stop when we reach the first uninteresting part (but still include that target to show where the last interesting part moves).
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

    def initialize(interesting_faces, interesting_corners, staying_mode, color_scheme, letter_scheme = nil)
      raise TypeError unless interesting_faces.all? { |f| f.is_a?(Face) }
      raise TypeError unless interesting_corners.all? { |f| f.is_a?(Corner) }
      unless %i[show_staying omit_staying].include?(staying_mode)
        raise ArgumentError
      end
      raise TypeError unless color_scheme.is_a?(ColorScheme)
      unless letter_scheme.nil? || letter_scheme.is_a?(ColorScheme)
        raise TypeError
      end

      @interesting_faces = interesting_faces
      @interesting_corners = interesting_corners
      @show_staying = staying_mode == :show_staying
      @color_scheme = color_scheme
      @skewb_state = @color_scheme.solved_skewb_state
      @letter_scheme = letter_scheme
    end

    def find_complete_source_cycle(part)
      complete_cycle = []
      current_part = part
      loop do
        complete_cycle.push(current_part)
        break if complete_cycle.length > 1 && current_part == part

        next_part_colors = current_part.rotations.map { |r| @skewb_state[yield r] }
        current_part = @color_scheme.part_for_colors(part.class, next_part_colors)
      end
      PartCycle.new(@letter_scheme, complete_cycle)
    end

    # Finds permutation cycles of parts.
    def find_part_target_cycles(interesting_parts, &make_coordinate)
      used_parts = []
      interesting_parts.collect_concat do |part|
        if (used_parts & part.rotations).empty?
          cycle = find_complete_source_cycle(part, &make_coordinate).simplify(interesting_parts).reverse
          used_parts += cycle.parts
          if @show_staying || !cycle.trivial?
            [cycle]
          else
            []
          end
        else
          []
        end
      end
    end

    # Finds where each part comes from.
    def find_part_sources(interesting_parts, &make_coordinate)
      interesting_parts.collect_concat do |part|
        source_cycle = find_complete_source_cycle(part, &make_coordinate)
        if @show_staying || !source_cycle.trivial?
          [source_cycle.first_move.reverse]
        else
          []
        end
      end
    end

    # Describes where each interesting piece comes from.
    def source_descriptions(algorithm)
      algorithm.apply_temporarily_to(@skewb_state) do
        find_part_sources(@interesting_faces, &SkewbCoordinate.method(:for_center)) +
          find_part_sources(@interesting_corners, &SkewbCoordinate.method(:for_corner))
      end.sort
    end

    # Describes what kind of tranformation the alg does in terms of piece cycles.
    def transformation_descriptions(algorithm)
      algorithm.apply_temporarily_to(@skewb_state) do
        find_part_target_cycles(@interesting_faces, &SkewbCoordinate.method(:for_center)) +
          find_part_target_cycles(@interesting_corners, &SkewbCoordinate.method(:for_corner))
      end.sort
    end
  end
end
