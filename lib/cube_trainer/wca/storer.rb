# frozen_string_literal: true

require 'cube_trainer/xdg_helper'
require 'pathname'

module CubeTrainer
  module WCA
    # Helper class to store WCA exports locally.
    class Storer
      include XDGHelper

      def initialize
        ensure_cache_directory_exists
      end

      def subdirectory
        Pathname.new(super) + 'wca_exports' # rubocop:disable Style/StringConcatenation
      end

      def wca_export_path(filename)
        cache_file(filename)
      end

      def wca_export_file_exists?(filename)
        File.exist?(wca_export_path(filename))
      end
    end
  end
end
