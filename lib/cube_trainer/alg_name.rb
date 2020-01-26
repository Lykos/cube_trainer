module CubeTrainer

  class AlgName

    SEPARATOR = ' + '

    def name
      raise NotImplementedError
    end
    
    def to_s
      name
    end

    def self.from_raw_data(input)
      if input.include?(SEPARATOR)
        CombinedAlgName.new(input.split(SEPARATOR))
      else
        SimpleAlgName.new(input)
      end
    end
  
    def to_raw_data
      name
    end

    def eql?(other)
      self.class.equal?(other.class) && name == other.name
    end
  
    alias == eql?
  
    def hash
      name.hash
    end

    def +(other)
      CombinedAlgName.new([self, other])
    end
  end

  class SimpleAlgName < AlgName
    
    def initialize(name)
      raise ArgumentError if name.include?(SEPARATOR)
      @name = name
    end

    attr_reader :name
    
  end

  # Note that there is only one level of combining algs.
  # This is caused by the fact that the structure couldn't be recognized because combining algs is associative.
  class CombinedAlgName < AlgName
    
    def initialize(sub_names)
      @sub_names = sub_names.collect_concat do |s|
        case s
        when CombinedAlgName then s.sub_names
        when SimpleAlgName then [s]
        else raise TypeError, "Bad alg name subtype #{s.class}."
        end
      end
    end

    attr_reader :sub_names

    def name
      @sub_names.join(SEPARATOR)
    end

  end

end
