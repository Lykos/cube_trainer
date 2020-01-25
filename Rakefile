require 'rake/extensiontask'

RBUIC = '/usr/local/bin/rbuic4'
UIFILES = FileList.new('ui/**/*.ui')

def ui_to_rb(f)
  f.sub(/^ui\//, 'lib/').sub(/.ui$/, '_ui.rb')
end

def rb_to_ui(f)
  f.sub(/^lib\//, 'ui/').sub(/_ui\.rb$/, '.ui')
end

desc 'generate all Qt UI files using rbuic4'
task :uic => UIFILES.collect { |f| ui_to_rb(f) }

Rake::ExtensionTask.new('cube_trainer/native')

rule(/^lib\/.*_ui\.rb$/ => lambda { |f| rb_to_ui(f) }) do |t|
  ui_file = t.source
  rb_file = t.name
  if !system(RBUIC, ui_file, '-o', rb_file)
    STDERR.puts "Failed to compile #{ui_file}."
  end
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
rescue LoadError
end

