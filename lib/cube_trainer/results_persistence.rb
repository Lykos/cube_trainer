require 'yaml'
require 'cube_trainer/result'
require 'cube_trainer/cube'
require 'cube_trainer/letter_pair'
require 'cube_trainer/xdg_helper'
require 'sqlite3'

module CubeTrainer

  class ResultsPersistence
  
    def initialize(db)
      @db = db
      db.execute 'CREATE TABLE IF NOT EXISTS Results(Id INTEGER PRIMARY KEY, Mode TEXT, Timestamp INTEGER, TimeS REAL, Input TEXT, FailedAttempts INTEGER, Word TEXT)'
    end
  
    def self.create_in_memory
      db = SQLite3::Database.new(':memory:')
      ResultsPersistence.new(db)
    end
  
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
  
    def load_results(mode)
      @load_results_stm ||= @db.prepare('SELECT Mode, Timestamp, TimeS, Input, FailedAttempts, Word FROM Results WHERE Mode = ?')
      @load_results_stm.execute(mode.to_s).map { |r| Result.from_raw_data(r) }
    end
  
    def replace_word(mode, input, word)
      @replace_results_stm ||= @db.prepare 'UPDATE Results SET Word = ? WHERE Mode = ? and Input = ?';
      @replace_results_stm.execute(word, mode.to_s, input.to_s)
    end
    
    # Delete all results that happened after the given time.
    # Useful if you screwed up and want to delete results of the last 10 seconds.
    def delete_after_time(mode, time)
      @delete_after_time_stm ||= @db.prepare 'DELETE FROM Results WHERE Mode = ? and Timestamp > ?';
      @delete_after_time_stm.execute(mode.to_s, time.to_i)
    end
  
    def record_result(result)
      @record_result_stm ||= @db.prepare('INSERT INTO Results(Mode, Timestamp, TimeS, Input, FailedAttempts, Word) Values(?, ?, ?, ?, ?, ?)')
      @record_result_stm.execute(result.to_raw_data)
    end
  end

end
