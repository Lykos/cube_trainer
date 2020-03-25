# frozen_string_literal: true

require 'cube_trainer/training/results_persistence'
require 'cube_trainer/training/result'

def result_exists(result)
  CubeTrainer::Training::Result.exists?(
    hostname: CubeTrainer::Training::Result.current_hostname,
    created_at: result.timestamp
  )
end

total_migrated = 0
total_existing = 0
persistence = CubeTrainer::Training::ResultsPersistence.create_for_production
persistence.load_modes.each do |mode|
  puts "Loading results for #{mode}."
  results = persistence.load_results(mode)
  puts "Trying to migrating #{results.length} results for mode #{mode}."
  existing = 0
  results.each do |r|
    if result_exists(r)
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
