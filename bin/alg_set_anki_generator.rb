#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'alg_set_anki_generator'
require 'alg_set_anki_generator_options'

include CubeTrainer

options = AlgSetAnkiGeneratorOptions.parse(ARGV)
generator = AlgSetAnkiGenerator.new(options)
generator.generate
