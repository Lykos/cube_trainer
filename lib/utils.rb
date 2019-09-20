module CubeTrainer

  def only(array)
    raise ArgumentError if array.length != 1
    array.first
  end

end
