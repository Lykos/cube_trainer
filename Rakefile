# frozen_string_literal: true

def ui_to_rb(filename)
  filename.sub(%r{^ui/}, 'lib/').sub(/.ui$/, '_ui.rb')
end

def rb_to_ui(filename)
  filename.sub(%r{^lib/}, 'ui/').sub(/_ui\.rb$/, '.ui')
end

rule(%r{^lib/.*_ui\.rb$} => [lambda do |f|
                               filename = rb_to_ui(f)
                               [filename, File.dirname(filename)]
                             end]) do |t|
  ui_file = t.source
  rb_file = t.name
  warn "Failed to compile #{ui_file}." unless system(RBUIC, ui_file, '-o', rb_file)
end

RBUIC = '/usr/local/bin/rbuic4'
UIFILES = FileList['ui/**/*.ui']
COMPILED_UIFILES = UIFILES.map { |f| ui_to_rb(f) }
COMPILED_UIFILES_DIRECTORIES = COMPILED_UIFILES.map { |f| File.dirname(f) }.uniq

COMPILED_UIFILES_DIRECTORIES.each { |d| directory d }

desc 'generate all Qt UI files using rbuic4'
task uic: COMPILED_UIFILES

begin
  require 'rake/clean'
  CLOBBER.include(COMPILED_UIFILES)
rescue LoadError => e
  warn "Couldn't extend clobber list: #{e}"
end

begin
  require 'rake/extensiontask'
  Rake::ExtensionTask.new('cube_trainer/native')
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
