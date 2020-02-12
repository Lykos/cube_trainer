# frozen_string_literal: true

require 'cube_trainer/xdg_helper'
require 'pathname'

module CubeTrainer
  class WCAStorer
    include XDGHelper

    def initialize
      ensure_data_directory_exists
    end

    def subdirectory
      Pathname.new(super) + 'wca_exports'
    end

    def wca_export_path(filename)
      data_file(filename)
    end

    def has_wca_export_file(filename)
      File.exist?(wca_export_path(filename))
    end
  end
end
