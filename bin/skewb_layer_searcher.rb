#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/anki/skewb_layer_anki_generator'
require 'cube_trainer/skewb_layer_searcher_options'

options = CubeTrainer::SkewbLayerSearcherOptions.parse(ARGV)
CubeTrainer::Anki::SkewbLayerAnkiGenerator.new(options).run
