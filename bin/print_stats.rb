#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'results_persistence'
require 'stats_computer'
require 'cube'

results = ResultsPersistence.new.load_results
computer = StatsComputer.new
grouped_results = results.group_by { |c| c.cubie.inspect }
grouped_averages = grouped_results.collect { |c, rs| [c, computer.average_time(rs)] }
sorted_averages = grouped_averages.sort_by { |t| t[1] }
sorted_averages.each { |c, t| puts "#{c} #{t}" }
