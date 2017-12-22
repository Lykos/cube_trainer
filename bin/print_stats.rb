#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'results_persistence'
require 'stats_computer'
require 'cube'

results = ResultsPersistence.create_for_production.load_results
computer = StatsComputer.new
results.each do |k, v|
  puts k
  grouped_results = v.group_by { |c| c.input.to_s }
  grouped_averages = grouped_results.collect { |c, rs| [c, computer.average_time(rs)] }
  sorted_averages = grouped_averages.sort_by { |t| -t[1] }
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
  puts
end
