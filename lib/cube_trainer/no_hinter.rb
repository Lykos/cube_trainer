module CubeTrainer
  
  class NoHinter
    def initialize(entries)
      @entries = entries
    end

    attr_reader :entries
    
    def hints(*args)
      []
    end
  end

end
