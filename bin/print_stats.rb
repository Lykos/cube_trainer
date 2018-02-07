#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'results_persistence'
require 'stats_computer'
require 'cube'
require 'options'

include CubeTrainer

def print_stats(results)
  computer = StatsComputer.new(results)
  computer.averages.each { |c, t| puts "#{c}  #{t.round(2)} s" }
  avg = computer.total_average
  puts "Average #{avg.round(2)}"
  computer.bad_results.each do |cutoff, number|
    puts "#{number} are sup #{cutoff} s"
  end
end

options = Options.parse(ARGV)
results = ResultsPersistence.create_for_production.load_results
if options.commutator_info
  print_stats(results[options.commutator_info.result_symbol])
else
  results.each do |k, v|
    puts k
    print_stats(v)
    puts
  end
end
