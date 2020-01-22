require 'xdg'
require 'pathname'
require 'fileutils'

module CubeTrainer

  module XDGHelper
  
    include XDG::BaseDir::Mixin
  
    def subdirectory
      'cube_trainer'
    end
  
    def data_directory
      Pathname.new(data.home.to_s)
    end
  
    def cache_directory
      Pathname.new(cache.home.to_s)
    end
  
    def data_file(filename)
      data_directory + filename
    end
  
    def cache_file(filename)
      cache_directory + filename
    end
  
    def ensure_data_directory_exists
      if !File.exists?(data_directory)
        FileUtils.mkpath(data_directory)
      end
    end

    def ensure_cache_directory_exists
      if !File.exists?(cache_directory)
        FileUtils.mkpath(cache_directory)
      end
    end
    
  end

end
