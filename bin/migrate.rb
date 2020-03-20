#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'db/migrate'))

require 'active_record'
require 'cube_trainer/training/results_persistence'
require '20200320214513_add_success_num_hints_columns'

# TODO Refactor this file to only include the migration itself and find a proper way for migrations

db_file = CubeTrainer::Training::ResultsPersistence::DBConnectionHelper.new.db_file
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: db_file)
AddSuccessNumHintsColumns.migrate(:up)


