require 'cube'
require 'skewb_state'

module CubeTrainer

  class SkewbTransformationDescriber

    TOP_BOTTOM_CORNERS = 
    DESCRIPTION_SEPARATOR = ', '
    DOUBLE_ARROW = ' <-> '
    ARROW = ' -> '

    def initialize(interesting_faces, interesting_corners)
      @interesting_faces = interesting_faces
      @interesting_corners = interesting_corners
      @skewb_state = SkewbState.solved
    end

    # Finds permutation cycles of parts. Note that cycles of length 1 (i.e. parts that stay) are excluded.
    def find_part_cycles(interesting_parts, &make_coordinate)
      used_parts = []
      cycles = []
      interesting_parts.each do |part|
        next unless (used_parts & part.rotations).empty?
        complete_cycle = []
        current_part = part
        loop do
          complete_cycle.push(current_part)
          break if complete_cycle.length > 1 && current_part == part
          used_parts.push(current_part)
          next_part_colors = current_part.rotations.map { |r| @skewb_state[yield r] }
          current_part = part.class.for_colors(next_part_colors)
        end
        cycle = []
        complete_cycle.reverse.each do |part|
          cycle.push(part)
          # Stop when we reach the first uninteresting part (but still include that target to show where the last interesting target moves).
          break unless interesting_parts.include?(current_part)
          # Stop after we reach a rotation of the first part (but still include that target to show the rotation or the end of the cycle).
          break if cycle.length > 1 && current_part.rotations.include?(part)          
        end
        cycles.push(cycle) unless cycle == [part, part]
      end
      cycles
    end

    def description(algorithm)
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
