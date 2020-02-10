require 'cube_trainer/sticker_cycle'

module CubeTrainer
  
  class PartCycleFactory
    
    def initialize(cube_size, incarnation_index)
      CubeState.check_cube_size(cube_size)
      raise ArgumentError, "Invalid incarnation index #{incarnation_index}." unless incarnation_index.is_a?(Integer) && incarnation_index >= 0
      @cube_size = cube_size
      @incarnation_index = incarnation_index
      @cache = {}
    end

    def coordinates(part)
      @cache[part] ||= Coordinate.solved_positions(part, @cube_size, @incarnation_index)
    end

    def multi_corner_twist(corners)
      raise TypeError, 'Cycles of weird piece types are not supported.' unless corners.all? { |p| p.is_a?(Corner) }
      cycles = corners.map { |c| StickerCycle.new(@cube_size, coordinates(c)) }
      StickerCycles.new(@cube_size, cycles)
    end

    def construct(parts) 
      raise TypeError, 'Cycles of weird piece types are not supported.' unless parts.all? { |p| p.is_a?(Part) }
      raise ArgumentError, 'Cycles of length smaller than 2 are not supported.' if parts.length < 2
      raise TypeError, "Cycles of heterogenous piece types #{parts.inspect} are not supported." if parts.any? { |p| p.class != parts.first.class }
      unless @incarnation_index < parts.first.num_incarnations(@cube_size)
        raise ArgumentError, "Incarnation index #{@incarnation_index} for cube size #{@cube_size} is not supported for #{parts.first.inspect}."
      end
      part_coordinates = parts.map { |p| coordinates(p) }
      cycles = part_coordinates.transpose.map { |c| StickerCycle.new(@cube_size, c) }
      StickerCycles.new(@cube_size, cycles)
    end
    
  end

end
