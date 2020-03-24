#!/usr/bin/ruby
# frozen_string_literal: true

require File.expand_path('../../config/application',  __FILE__)

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))

require 'active_record'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

require 'cube_trainer/training/results_persistence'
require 'models/cube_trainer/training'
require 'models/cube_trainer/training/result'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/development.sqlite3'
)

total_migrated = 0
total_existing = 0
persistence = CubeTrainer::Training::ResultsPersistence.create_for_production
persistence.load_modes.each do |mode|
  puts "Loading results for #{mode}."
  results = persistence.load_results(mode)
  puts "Trying to migrating #{results.length} results for mode #{mode}."
  existing = 0
  results.each do |r|
    if CubeTrainer::Training::Result.exists?(created_at: r.timestamp)
      existing += 1
    else 
      r.to_result.save!
    end
  end
  migrated = results.length - existing
  puts "Migrated #{migrated} results for mode #{mode}."
  puts "#{existing} omitted because they already existed."
  puts
  total_migrated += migrated
  total_existing += existing
end
puts "Migrated #{total_migrated} results in total."
puts "#{total_existing} omitted in total becauset they already existed."
