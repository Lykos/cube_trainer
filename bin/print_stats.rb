#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'results_persistence'
require 'stats_computer'
require 'cube'
require 'options'

def print_stats(results)
  computer = StatsComputer.new
  sorted_averages = computer.compute_stats(results)
  sorted_averages.each { |c, t| puts "#{c}  #{t.round(2)} s" }
  avg = sorted_averages.collect { |c, t| t }.reduce(:+) / sorted_averages.length
  puts "Average #{avg.round(2)}"
  if sorted_averages.length > 20 then
    # TODO cutoff uses 0.5 step length, do something smarter that depends on the values.
    base_cutoff = (sorted_averages[9][1] * 2).floor / 2.0
    base_cutoff.step(base_cutoff + 1.5, 0.5) do |cutoff|
      above_cutoff = sorted_averages.count { |v| v[1] > cutoff }
      puts "#{above_cutoff} are sup #{cutoff} s"
    end
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
