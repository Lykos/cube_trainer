# frozen_string_literal: true

begin
  require 'rake/extensiontask'
  Rake::ExtensionTask.new('twisty_puzzles/native')
rescue LoadError => e
  warn "Couldn't create extension task: #{e}"
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec, [] => :compile) do |_t|
    # TODO: Find the proper way to do this
    ENV['RANTLY_VERBOSE'] ||= '0'
  end
  CLOBBER.include('coverage')
  CLOBBER.include('profiles')
  CLOBBER.include('spec/examples.txt')
  task default: :spec
rescue LoadError => e
  warn "Couldn't create spec task: #{e}"
end
