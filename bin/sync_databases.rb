# frozen_string_literal: true

require 'cube_trainer/training/database_syncer'

CubeTrainer::Training::DatabaseSyncer.new(CubeTrainer::Training::Result).sync!
