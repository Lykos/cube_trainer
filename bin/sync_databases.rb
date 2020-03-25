#!/usr/bin/ruby
# frozen_string_literal: true

require 'cube_trainer/training/sync_databases'

CubeTrainer::Result::DatabaseSyncer.new(CubeTrainer::Training::Result).sync!
