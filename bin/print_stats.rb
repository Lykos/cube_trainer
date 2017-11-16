#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'results_persistence'
require 'stats_computer'
require 'cube'

results = ResultsPersistence.new.load_results
computer = StatsComputer.new
results.each do |k, v|
  puts k
  grouped_results = v.group_by { |c| c.input.to_s }
  grouped_averages = grouped_results.collect { |c, rs| [c, computer.average_time(rs)] }
  sorted_averages = grouped_averages.sort_by { |t| -t[1] }
  sorted_averages.each { |c, t| puts "#{c} #{t}" }
  avg = sorted_averages.collect { |c, t| t }.reduce(:+) / sorted_averages.length
  puts "Average #{avg}"
  puts
end
