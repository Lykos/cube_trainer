#!/usr/bin/rubyn
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'move'
require 'algorithm'
require 'options'
require 'skewb_layer_finder'
require 'color_scheme'
require 'skewb_state'
require 'parser'
require 'cube_print_helper'

include CubeTrainer
include CubePrintHelper

SEARCH_DEPTH = 6

options = Options.parse(ARGV)

puts 'Enter scramble in fixed corner notation.'

scramble_string = gets.chomp
scramble = parse_fixed_corner_skewb_algorithm(scramble_string)

layer_finder = SkewbLayerFinder.new(options.restrict_colors)
skewb_state = ColorScheme::BERNHARD.solved_skewb_state
scramble.apply_to(skewb_state)
puts skewb_string(skewb_state, :color)

layer_solutions = layer_finder.find_solutions(skewb_state, SEARCH_DEPTH)
if layer_solutions.solved?
  puts "Optimal solution has #{layer_solutions.length} moves."
  layer_solutions.extract_algorithms.each do |color, algs|
    puts color
    puts algs
    puts
  end
else
  puts "No solution found with the given limit of #{SEARCH_DEPTH} moves."
end
