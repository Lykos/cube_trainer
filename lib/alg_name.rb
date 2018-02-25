module CubeTrainer

  class AlgName
    def initialize(name)
      @name = name
    end

    attr_reader :name

    def to_s
      @name
    end

    def self.from_raw_data(input)
      new(input)
    end
  
    # Encoding for YAML (and possibly others)
    def encode_with(coder)
      coder['name'] = @name
    end

    def to_raw_data
      @name
    end

    def eql?(other)
      self.class.equal?(other.class) && @name == other.name
    end
  
    alias == eql?
  
    def hash
      @name.hash
    end
  end

end
