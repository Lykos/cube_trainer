#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'options'

include CubeTrainer

puts Options::COMMUTATOR_TYPES.keys
