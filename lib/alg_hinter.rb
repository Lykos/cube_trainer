module CubeTrainer

  class AlgHinter

    def initialize(hints)
      @entries = hints.to_a.freeze
      @hints = hints.map { |k, v| [k, [v]] }.to_h
      @hints.default = []
      @hints.freeze
    end

    attr_reader :entries

    def hints(name)
      @hints[name]
    end
    
  end
  
end
