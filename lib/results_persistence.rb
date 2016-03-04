require 'yaml'
require 'result'

class ResultsPersistence

  # TODO Migrate to XDG
  def results_file
    File.join(ENV['HOME'], '.blind_trainer', 'results.yml')
  end

  def load_results
    if !File.exists?(results_file)
      []
    else
      YAML::load(File.read(results_file))
    end
  end

  def store_results(results)
    File.open(results_file, 'w+') do |f|
      YAML::dump(results, f)
    end
  end

end
