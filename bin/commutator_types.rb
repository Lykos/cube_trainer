#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/commutator_options'

puts CubeTrainer::CommutatorOptions::COMMUTATOR_TYPES.keys
