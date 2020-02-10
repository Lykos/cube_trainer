require 'rspec-prof'
require 'simplecov'

RSpec.configure do |config|
  config.example_status_persistence_file_path = 'spec/examples.txt'
end

# This must be before we require cube_trainer.
SimpleCov.start do
  add_filter '/spec/'
end

require 'cube_trainer'
require 'generator_helpers'
require 'shrink_helpers'

include CubeTrainer
