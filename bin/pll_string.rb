#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'twisty_puzzles'
require 'twisty_puzzles'
require 'twisty_puzzles'

# rubocop:disable Style/MixinUsage
include CubeTrainer::Core
include CubePrintHelper
# rubocop:enable Style/MixinUsage

puts 'Enter LL scramble'
scramble_string = gets.chomp
scramble = parse_algorithm(scramble_string)
state = TwistyPuzzles::ColorScheme::BERNHARD.solved_cube_state(3)
scramble.apply_to(state)
puts ll_string(state, :color)
