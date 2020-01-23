#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/anki/cube_visualizer'
require 'cube_trainer/anki/cache'
require 'cube_trainer/anki/cube_visualizer_options'
require 'net/http'

include CubeTrainer

options = CubeVisualizerOptions.parse(ARGV)

fmt = File.extname(options.output)[1..-1].to_sym
cache = options.cache ? Cache.new('cube_visualizer') : nil
visualizer = CubeVisualizer.new(Net::HTTP, cache, sch: options.color_scheme, fmt: fmt, stage: options.stage_mask)
cube_state = options.color_scheme.solved_cube_state(options.cube_size)
options.algorithm.apply_to(cube_state)
visualizer.fetch_and_store(cube_state, options.output)
