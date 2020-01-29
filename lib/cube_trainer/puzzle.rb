module CubeTrainer

  class Puzzle
    
    def initialize(name)
      @name = name
    end

    attr_reader :name

    def eql?(other)
      self.class == other.class && self.name == other.name
    end

    def hash
      @hash ||= [self.class, @name].hash
    end
    
    alias == eql?
    
    NXN_CUBE = Puzzle.new('nxn cube')
    SKEWB = Puzzle.new('skewb')
    
  end

end
