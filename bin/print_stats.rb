#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/commutator_options'
require 'cube_trainer/core/cube'
require 'cube_trainer/stats_computer'
require 'yaml'

options = CubeTrainer::CommutatorOptions.parse(ARGV)
computer = CubeTrainer::StatsComputer.new(Time.now, options)

# Detailed stats
computer.averages.each { |c, t| puts "#{c}  #{t.round(2)} s" }

# Stats on bad results
puts
puts '# Worst Cases'
computer.bad_results.each do |cutoff, number|
  puts "#{number} are sup #{cutoff.round(3)} s"
end

# Overall progress
avg = computer.total_average
puts
puts '# Progress'
puts "Average time per alg: #{avg.round(2)} s"
puts "Average time per alg 24 hours ago: #{computer.old_total_average.round(2)} s"

# Part of the solve
puts
puts '# Stats'
lolstats = computer.expected_time_per_type_stats
lolstats.each do |stats|
  puts "#{stats[:name]}: "
  puts "On average #{stats[:expected_algs].round(2)} algs taking #{stats[:average].round(2)} s " \
       'each on average.'
  puts "Average time spent in total: #{stats[:total_time].round(2)} s " \
       "(#{(stats[:weight] * 100).round(2)}%)"
  puts
end
puts "Total time: #{lolstats.map { |stats| stats[:total_time] }.reduce(:+)} s"
