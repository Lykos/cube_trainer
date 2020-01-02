#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'skewb_layer_searcher'
require 'skewb_state'

include CubeTrainer

layer_searcher = SkewbLayerSearcher.new
puts layer_searcher.calculate.length
