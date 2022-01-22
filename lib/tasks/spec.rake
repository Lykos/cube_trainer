# frozen_string_literal: true

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec_profile) do |t|
    t.rspec_opts = '--profile'
  end

  RSpec::Core::RakeTask.new(:spec_failures) do |t|
    t.rspec_opts = '--only-failures'
  end
rescue LoadError # rubocop:disable Lint/SuppressedException
end
