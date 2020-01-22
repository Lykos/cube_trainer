require 'cube_trainer/xdg_helper'

module CubeTrainer

  class Cache

    class CacheHelper

      include XDGHelper

      def initialize(namespace)
        @namespace = namespace
        ensure_cache_directory_exists
      end

      def subdirectory
        Pathname.new(super) + 'cache' + @namespace
      end
      
    end

    def initialize(namespace)
      @helper = CacheHelper.new(namespace)
    end

    def [](key)
      raise TypeError unless key.is_a?(String)
      file = @helper.cache_file(key)
      File.read(file) if File.exist?(file)
    end

    def []=(key, value)
      raise TypeError unless key.is_a?(String)
      file = @helper.cache_file(key)
      File.open(file, 'wb') { |f| f.write(value) }
    end
    
  end
  
end
