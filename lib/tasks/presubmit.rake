# frozen_string_literal: true

begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop) do |t|
    t.options = ['--display-cop-names']
  end

  desc 'Run all types of tests and lints'
  task presubmit: ['rubocop', 'npm:build', 'npm:lint', 'npm:test_ci', 'spec']
rescue LoadError
  warn 'Coudn\'t load Rubocop.'
end
