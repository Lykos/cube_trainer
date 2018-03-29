#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'move'
require 'options'
require 'skewb_layer_finder'
require 'skewb_state'

include CubeTrainer

SEARCH_DEPTH = 5

options = Options.parse(ARGV)

puts 'Enter scramble with spaces between moves.'
scramble_string = gets.chomp
scramble = Algorithm.new(scramble_string.split(' ').collect { |move_string| parse_skewb_move(move_string) })

layer_finder = SkewbLayerFinder.new
skewb_state = SkewbState.solved
scramble.apply_to(skewb_state)
puts skewb_state.to_s

layer_solutions = layer_finder.find_layer(skewb_state, SEARCH_DEPTH, options.restrict_colors)
puts "Optimal solution has #{layer_solutions.length} moves."
layer_solutions.extract_algorithms.each do |color, algs|
  puts color
  puts algs
  puts
end
