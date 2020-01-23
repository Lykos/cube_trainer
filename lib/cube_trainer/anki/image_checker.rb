require 'filemagic'

module CubeTrainer

  class ImageChecker

    def initialize(format)
      @format = format
      @magic = FileMagic.new
    end

    def check(data)
      info = @magic.buffer(data)
      raise if @format == :jpg && !info.start_with?('JPEG')
    end
   
  end

end
