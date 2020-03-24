# frozen_string_literal: true

begin
  require 'rake/extensiontask'
  Rake::ExtensionTask.new('cube_trainer/native')
rescue LoadError => e
  warn "Couldn't create extension task: #{e}"
end
