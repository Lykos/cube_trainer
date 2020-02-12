# frozen_string_literal: true

require 'xdg'
require 'pathname'
require 'fileutils'

module CubeTrainer
  # Helper class to access the files in the XDG directories.
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
      FileUtils.mkpath(data_directory) unless File.exist?(data_directory)
    end

    def ensure_cache_directory_exists
      FileUtils.mkpath(cache_directory) unless File.exist?(cache_directory)
    end
  end
end
