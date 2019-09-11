#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'stats_computer'
require 'cube'
require 'options'
require 'yaml'

include CubeTrainer

options = Options.parse(ARGV)
computer = StatsComputer.new(options)

# Detailed stats
computer.averages.each { |c, t| puts "#{c}  #{t.round(2)} s" }

# Summaries
avg = computer.total_average
expected_targets = computer.expected_targets
puts "Average time per alg: #{avg.round(2)} s"
puts "Average time per alg 24 hours ago: #{computer.old_total_average.round(2)} s"
puts "Average number of algs: #{expected_targets.round(2)}"
avg_total = avg * expected_targets
puts "Average time spent in total: #{avg_total.round(2)} s"

# Stats on bad results
computer.bad_results.each do |cutoff, number|
  puts "#{number} are sup #{cutoff.round(2)} s"
end
