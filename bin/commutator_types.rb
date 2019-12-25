#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'options'

include CubeTrainer

puts Options::COMMUTATOR_TYPES.keys
