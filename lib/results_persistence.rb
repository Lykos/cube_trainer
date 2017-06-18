require 'yaml'
require 'result'
require 'cube'
require 'fileutils'
require 'letter_pair'
require 'xdg'
require 'pathname'

class ResultsPersistence

  include XDG::BaseDir::Mixin

  def subdirectory
    'cube_trainer'
  end

  def results_file
    Pathname.new(data.home.to_s) + 'results.yml'
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
    if !File.exists?(dirname)
      FileUtils.mkpath(dirname)
    end
    File.open(results_file, 'w') do |f|
      YAML::dump(results, f)
    end
  end

end
