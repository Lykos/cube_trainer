require 'cube_trainer'

include CubeTrainer

RSpec.configure do |config|
  config.example_status_persistence_file_path = "spec/examples.txt"
end
