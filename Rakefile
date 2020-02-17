# frozen_string_literal: true

require 'rake/extensiontask'
require 'rspec/core/rake_task'

RBUIC = '/usr/local/bin/rbuic4'
UIFILES = FileList.new('ui/**/*.ui')

# TODO: Find the proper way to do this
ENV['RANTLY_VERBOSE'] ||= '0'

def ui_to_rb(f)
  f.sub(%r{^ui/}, 'lib/').sub(/.ui$/, '_ui.rb')
end

def rb_to_ui(f)
  f.sub(%r{^lib/}, 'ui/').sub(/_ui\.rb$/, '.ui')
end

desc 'generate all Qt UI files using rbuic4'
task uic: UIFILES.collect { |f| ui_to_rb(f) }

rule(%r{^lib/.*_ui\.rb$} => ->(f) { rb_to_ui(f) }) do |t|
  ui_file = t.source
  rb_file = t.name
  warn "Failed to compile #{ui_file}." unless system(RBUIC, ui_file, '-o', rb_file)
end

Rake::ExtensionTask.new('cube_trainer/native')

RSpec::Core::RakeTask.new(:spec)

task default: :spec

