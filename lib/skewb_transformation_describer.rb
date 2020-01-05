# coding: utf-8
require 'cube'
require 'skewb_state'

module CubeTrainer

  class SkewbTransformationDescriber

    TOP_BOTTOM_CORNERS = 
    DESCRIPTION_SEPARATOR = ', '
    DOUBLE_ARROW = ' ↔ '
    ARROW = ' → '

    def initialize(interesting_faces, interesting_corners, show_staying)
      @interesting_faces = interesting_faces
      @interesting_corners = interesting_corners
      @show_staying = show_staying
      @skewb_state = SkewbState.solved
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
      complete_cycle
    end

    # Finds permutation cycles of parts.
    def find_part_cycles(interesting_parts, &make_coordinate)
      used_parts = []
      cycles = []
      interesting_parts.each do |part|
        next unless (used_parts & part.rotations).empty?
        cycle = []
        find_complete_cycle(part, &make_coordinate).reverse.each do |current_part|
          cycle.push(current_part)
          # Stop after we reach a rotation of the first part (but still include that target to show the rotation or the end of the cycle).
          break if cycle.length > 1 && part.rotations.include?(current_part)
          used_parts.push(current_part)
          # Stop when we reach the first uninteresting part (but still include that target to show where the last interesting target moves).
          break if (interesting_parts & part.rotations).empty?
        end
        cycles.push(cycle) if @show_staying || cycle != [part, part]
      end
      cycles
    end

    # Finds where each part comes from.
    def find_part_sources(interesting_parts, &make_coordinate)
      targets = []
      interesting_parts.each do |part|
        target_cycle = find_complete_cycle(part, &make_coordinate)
        targets.push(target_cycle[0..1].reverse) if @show_staying || target_cycle != [part, part]
      end
      targets
    end

    # Describes where each interesting piece comes from.
    def source_description(algorithm)
      algorithm.apply_temporarily_to(@skewb_state) do
        find_part_sources(@interesting_faces, &SkewbCoordinate.method(:center)) +
          find_part_sources(@interesting_corners, &SkewbCoordinate.method(:for_corner))
      end.map(&method(:part_target_description)).join(DESCRIPTION_SEPARATOR)
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
      algorithm.apply_temporarily_to(@skewb_state) do
        find_part_cycles(@interesting_faces, &SkewbCoordinate.method(:center)) +
          find_part_cycles(@interesting_corners, &SkewbCoordinate.method(:for_corner))
      end.map(&method(:part_cycle_description)).join(DESCRIPTION_SEPARATOR)
    end

    def part_cycle_description(cycle)
      raise ArgumentError unless cycle.length >= 2
      if cycle.length == 3 && cycle[0] == cycle[2]
        cycle[0..1].join(DOUBLE_ARROW)
      else
        cycle.join(ARROW)
      end
    end
    
  end

end
