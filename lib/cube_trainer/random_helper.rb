module CubeTrainer

  module RandomHelper
    
    # Distort the given value randomly by up to the given factor.
    def distort(value, factor)
      raise unless factor > 0 && factor < 1
      value * (1 - factor) + (factor * 2 * value * rand)
    end
  
  end
  
end
