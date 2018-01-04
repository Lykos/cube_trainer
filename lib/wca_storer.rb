require 'xdg_helper'
require 'pathname'

module CubeTrainer

  class WCAStorer
  
    include XDGHelper
  
    def subdirectory
      Pathname.new(super) + 'wca_exports'
    end
  
    def wca_export_path(filename)
      data_file(filename)
    end
  
    def has_wca_export_file(filename)
      File.exists?(wca_export_path(filename))
    end
    
  end

end
