require 'filemagic'

module CubeTrainer

  class ImageChecker

    def initialize(format)
      @format = format
      @magic = FileMagic.new
    end

    def valid?(data)
      info = @magic.buffer(data)
      case @format
      when :jpg
        info.start_with?('JPEG')        
      else
        raise NotImplementedError
      end
    end
   
  end

end
