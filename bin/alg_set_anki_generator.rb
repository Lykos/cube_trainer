#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/anki/alg_set_anki_generator'
require 'cube_trainer/anki/alg_set_anki_generator_options'

include CubeTrainer
include Anki

options = AlgSetAnkiGeneratorOptions.parse(ARGV)
generator = AlgSetAnkiGenerator.new(options)
generator.generate
