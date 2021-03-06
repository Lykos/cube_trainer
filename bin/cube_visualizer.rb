#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/anki/cube_visualizer'
require 'cube_trainer/anki/cache'
require 'cube_trainer/anki/cube_mask'
require 'cube_trainer/anki/cube_visualizer_options'
require 'net/http'

options = CubeTrainer::Anki::CubeVisualizerOptions.parse(ARGV)

fmt = File.extname(options.output)[1..].to_sym
cache = options.cache ? CubeTrainer::Anki::Cache.new('cube_visualizer') : nil
visualizer = CubeTrainer::Anki::CubeVisualizer.new(
  fetcher: Net::HTTP, cache: cache, sch: options.color_scheme, fmt: fmt, stage: options.stage_mask
)
cube_state = options.color_scheme.solved_cube_state(options.cube_size)
if options.solved_mask_name
  solved_mask = CubeTrainer::Anki::CubeMask.from_name(
    options.solved_mask_name, options.cube_size, :unknown
  )
  solved_mask.apply_to(cube_state)
end
options.algorithm.apply_to(cube_state)
visualizer.fetch_and_store(cube_state, options.output)
