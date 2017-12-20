require 'yaml'
require 'result'
require 'cube'
require 'letter_pair'
require 'xdg_helper'

class YamlPersistence

  include XDGHelper

  def subdirectory
    'cube_trainer'
  end

  def results_file
    data_file('results.yml')
  end

  def load_results
    if !File.exists?(results_file)
      {}
    else
      YAML::load(File.read(results_file))
    end
  end

  def store_results(results)
    dirname = results_file.dirname
    ensure_base_directory_exists
    File.open(results_file, 'w') do |f|
      YAML::dump(results, f)
    end
  end

end
