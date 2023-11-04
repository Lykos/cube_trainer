# frozen_string_literal: true

begin
  require 'rspec/core/rake_task'

  namespace :spec do
    desc 'Run RSpec with profiling turned on.'
    RSpec::Core::RakeTask.new(:profile) do |t|
      t.rspec_opts = '--profile'
    end

    desc 'Run RSpec but only run the examples that failed during the last run.'
    RSpec::Core::RakeTask.new(:failures) do |t|
      t.rspec_opts = '--only-failures'
    end
  end
rescue LoadError
  warn 'Coudn\'t load RSpec.'
end
