#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_visualizer'
require 'cube_visualizer_options'

include CubeTrainer

options = CubeVisualizerOptions.parse(ARGV)

fmt = File.extname(options.output)[1..-1].to_sym
visualizer = CubeVisualizer.new(sch: options.color_scheme, fmt: fmt)
cube_state = options.color_scheme.solved_cube_state(options.cube_size)
options.algorithm.apply_to(cube_state)
visualizer.fetch_and_store(cube_state, options.output)
