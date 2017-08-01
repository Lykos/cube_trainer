require 'xdg'
require 'pathname'
require 'fileutils'

module XDGHelper

  include XDG::BaseDir::Mixin

  def subdirectory
    'cube_trainer'
  end

  def base_directory
    Pathname.new(data.home.to_s)
  end

  def data_file(filename)
    base_directory + filename
  end

  def ensure_base_directory_exists
    if !File.exists?(base_directory)
      FileUtils.mkpath(base_directory)
    end
  end
  
end
