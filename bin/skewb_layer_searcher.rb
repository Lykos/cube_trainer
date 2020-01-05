#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'skewb_layer_searcher'
require 'skewb_state'
require 'cube_print_helper'

include CubeTrainer
include CubePrintHelper

state = SkewbState.solved
solutions = SkewbLayerSearcher.calculate
puts
puts "#{solutions.length} solutions:"
puts
solutions.each do |algs|
  algs.first.inverse.apply_temporarily_to(state) do
    puts skewb_string(state, :color)
    puts algs
    puts
  end
end
