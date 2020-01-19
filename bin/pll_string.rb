#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_print_helper'
require 'cube_state'
require 'parser'
require 'color_scheme'

include CubeTrainer
include CubePrintHelper

puts 'Enter LL scramble'
scramble_string = gets.chomp
scramble = parse_algorithm(scramble_string)
state = ColorScheme::BERNHARD.solved_cube_state(3)
state.apply_algorithm(scramble)
puts ll_string(state, :color)

