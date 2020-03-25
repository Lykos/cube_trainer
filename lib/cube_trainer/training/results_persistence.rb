# frozen_string_literal: true

require 'yaml'
require 'cube_trainer/training/legacy_result'
require 'cube_trainer/letter_pair'
require 'cube_trainer/utils/array_helper'
require 'cube_trainer/xdg_helper'
require 'sqlite3'

module CubeTrainer
  module Training
    # Class that talks to the results database.
    class ResultsPersistence
      include Utils::ArrayHelper

      def initialize(db)
        @db = db
        db.execute(<<~SQL)
          CREATE TABLE IF NOT EXISTS Results(Id INTEGER PRIMARY KEY,
                                             Mode TEXT,
                                             Timestamp INTEGER,
                                             TimeS REAL,
                                             Input TEXT,
                                             FailedAttempts INTEGER,
                                             Word TEXT,
                                             Success INTEGER DEFAULT 1,
                                             NumHints INTEGER DEFAULT 0)
        SQL
      end

      def self.create_in_memory
        db = SQLite3::Database.new(':memory:')
        ResultsPersistence.new(db)
      end

      # Helper class to initialize a DB Connection.
      class DBConnectionHelper
        include XDGHelper

        def initialize
          ensure_data_directory_exists
        end

        def db_file
          data_file('results.sqlite3')
        end
      end

      def self.create_for_production
        helper = DBConnectionHelper.new
        db = SQLite3::Database.new(helper.db_file.to_s)
        ResultsPersistence.new(db)
      end

      def load_modes
        @load_modes_stm ||= @db.prepare(<<~SQL)
          SELECT Mode FROM Results GROUP BY 1
        SQL
        @load_modes_stm.execute.map { |r| only(r).to_sym }
      end

      def load_results(mode)
        @load_results_stm ||= @db.prepare(<<~SQL)
          SELECT Mode, Timestamp, TimeS, Input, FailedAttempts, Word, Success, NumHints FROM Results WHERE Mode = ?
        SQL
        @load_results_stm.execute(mode.to_s).map { |r| LegacyResult.from_raw_data(r) }
      end

      # Delete all results that happened after the given time.
      # Useful if you screwed up and want to delete results of the last 10 seconds.
      def delete_after_time(mode, time)
        @delete_after_time_stm ||= @db.prepare(<<~SQL)
          DELETE FROM Results WHERE Mode = ? and Timestamp > ?
        SQL
        @delete_after_time_stm.execute(mode.to_s, time.to_i) # rubocop:disable Lint/NumberConversion
      end

      def record_result(result)
        @record_result_stm ||= @db.prepare(<<~SQL)
          INSERT INTO Results(Mode, Timestamp, TimeS, Input, FailedAttempts, Word, Success, NumHints) Values(?, ?, ?, ?, ?, ?, ?, ?)
        SQL
        @record_result_stm.execute(result.to_raw_data)
      end
    end
  end
end
