module CubeTrainer

  # Helper class that figures out whether the given configuration of the white pieces has already been seen modulo symmetries and the positions of the non-white pieces.
  class SkewbLayerDeduplicator

    def initialize
      @encodings = []
    end

    def has_layer?(skewb_state)
      @encodings.include?(encode(skewb_state))
    end

    def add_layer(skewb_state)
      @encodings.push(encode(skewb_state))
    end

    def encode(skewb_state)
      
    end
    
  end
  
end
