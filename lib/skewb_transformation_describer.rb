# coding: utf-8
require 'cube'
require 'skewb_state'

module CubeTrainer

  class SkewbTransformationDescriber

    TOP_BOTTOM_CORNERS = 
    DESCRIPTION_SEPARATOR = ', '
    DOUBLE_ARROW = ' ↔ '
    ARROW = ' → '

    class Cycle
      def initialize(parts)
        raise ArgumentError unless parts.length >= 2
        @parts = parts
      end

      attr_reader :parts

      def description_with_letters(letter_scheme)
        description_internal(@parts.map { |p| letter_scheme.letter(p) })
      end

      def description
        description_internal(parts)
      end

      def trivial?
        @parts.length <= 1 || @parts == [@parts[0], @parts[0]]
      end

      def simplify(interesting_parts)
        return self if @parts.empty?
        simplified_parts = []
        first_part = parts.first
        parts.each do |part|
          simplified_parts.push(part)   
          # Stop after we reach a rotation of the first part (but still include that target to show the rotation or the end of the cycle).
          break if simplified_parts.length > 1 && first_part.rotations.include?(part)
          # Stop when we reach the first uninteresting part (but still include that target to show where the last interesting part moves).
          break if (interesting_parts & part.rotations).empty?
        end
        Cycle.new(simplified_parts)
      end

      def reverse
        Cycle.new(@parts.reverse)
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

    def initialize(interesting_faces, interesting_corners, staying_mode, letter_scheme=nil)
      raise ArgumentError unless [:show_staying, :omit_staying].include?(staying_mode)
      @interesting_faces = interesting_faces
      @interesting_corners = interesting_corners
      @show_staying = staying_mode == [:show_staying]
      @skewb_state = SkewbState.solved
      @letter_scheme = letter_scheme
    end

    def find_complete_cycle(part, &make_coordinate)
      complete_cycle = []
      current_part = part
      loop do
        complete_cycle.push(current_part)
        break if complete_cycle.length > 1 && current_part == part
        next_part_colors = current_part.rotations.map { |r| @skewb_state[yield r] }
        current_part = part.class.for_colors(next_part_colors)
      end
      Cycle.new(complete_cycle)
    end

    # Finds permutation cycles of parts.
    def find_part_cycles(interesting_parts, &make_coordinate)
      used_parts = []
      interesting_parts.collect_concat do |part|
        if (used_parts & part.rotations).empty?
          cycle = find_complete_cycle(part, &make_coordinate).simplify(interesting_parts).reverse
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
        target_cycle = find_complete_cycle(part, &make_coordinate)
        if @show_staying || !target_cycle.trivial?
          [target_cycle.parts[0..1].reverse]
        else
          []
        end
      end
    end

    # Describes where each interesting piece comes from.
    def source_description(algorithm)
      join_descriptions(algorithm.apply_temporarily_to(@skewb_state) do
        find_part_sources(@interesting_faces, &SkewbCoordinate.method(:center)) +
          find_part_sources(@interesting_corners, &SkewbCoordinate.method(:for_corner))
      end.map(&method(:part_target_description)))
    end

    def part_target_description(source_target)
      raise ArgumentError unless source_target.length == 2
      if source_target[0] == source_target[1]
        "#{source_target[0]} stays"
      else
        source_target.join(ARROW)
      end
    end

    # Describes what kind of tranformation the alg does in terms of piece cycles.
    def transformation_description(algorithm)
      join_descriptions(algorithm.apply_temporarily_to(@skewb_state) do
        find_part_cycles(@interesting_faces, &SkewbCoordinate.method(:center)) +
          find_part_cycles(@interesting_corners, &SkewbCoordinate.method(:for_corner))
      end.map(&method(:part_cycle_description)))
    end

    def join_descriptions(descriptions)
      descriptions.sort.join(DESCRIPTION_SEPARATOR)
    end

    def part_cycle_description(cycle)
      if @letter_scheme
        cycle.description_with_letters(@letter_scheme)
      else
        cycle.description
      end
    end
    
  end

end
