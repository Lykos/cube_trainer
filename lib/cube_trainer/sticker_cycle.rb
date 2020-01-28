require 'set'
require 'cube_trainer/coordinate'
require 'cube_trainer/cube_state'
require 'cube_trainer/reversible_applyable'

module CubeTrainer

  class StickerCycle

    include ReversibleApplyable
    
    def initialize(cube_size, sticker_cycle)
      @cube_size = cube_size
      @sticker_cycle = sticker_cycle
    end

    attr_reader :cube_size, :sticker_cycle
    
    def apply_to(cube_state)
      raise TypeError unless cube_state.is_a?(CubeState)
      raise ArgumentError unless cube_state.n == @cube_size
      cube_state.apply_sticker_cycle(@sticker_cycle) if @sticker_cycle.length >= 2
    end
    
    def inverse
      StickerCycle.new(@cube_size, @sticker_cycle.reverse)
    end
  end
    
  class StickerCycles

    include ReversibleApplyable

    def initialize(cube_size, sticker_cycles)
      affected_set = Set[]
      sticker_cycles.each do |c|
        raise TypeError unless c.is_a?(StickerCycle)
        c.sticker_cycle.each { |s| raise ArgumentError unless affected_set.add?(s) }
      end
      @cube_size = cube_size
      @sticker_cycles = sticker_cycles
    end
    
    def apply_to(cube_state)
      raise TypeError unless cube_state.is_a?(CubeState)
      raise ArgumentError unless cube_state.n == @cube_size
      @sticker_cycles.each { |c| c.apply_to(cube_state) }
    end

    def inverse
      StickerCycles.new(@cube_size, @sticker_cycles.map { |s| s.inverse })
    end
  end

end
