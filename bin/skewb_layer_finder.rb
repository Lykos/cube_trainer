#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/core/parser'
require 'cube_trainer/core/skewb_state'
require 'cube_trainer/skewb_layer_finder_options'
require 'cube_trainer/skewb_layer_finder'
require 'cube_trainer/color_scheme'

SEARCH_DEPTH = 6

# rubocop:disable Style/MixinUsage
include CubeTrainer::Core
# rubocop:enable Style/MixinUsage

options = CubeTrainer::SkewbLayerFinderOptions.parse(ARGV)

puts 'Enter scramble in fixed corner notation.'

scramble_string = gets.chomp
scramble = parse_skewb_algorithm(scramble_string, SkewbNotation.fixed_corner)

layer_finder = CubeTrainer::SkewbLayerFinder.new(options.restrict_colors)
skewb_state = options.color_scheme.solved_skewb_state
scramble.apply_to(skewb_state)
puts skewb_state.colored_to_s

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
