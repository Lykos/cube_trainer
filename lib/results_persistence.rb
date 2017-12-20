require 'yaml'
require 'result'
require 'cube'
require 'letter_pair'
require 'xdg_helper'
require 'sqlite3'

class ResultsPersistence

  include XDGHelper

  def subdirectory
    'cube_trainer'
  end

  def old_results_file
    data_file('results.yml')
  end

  def db_file
    data_file('results.sqlite3')
  end

  def initialize
    @db = SQLite3::Database.new(db_file.to_s)
    @db.execute 'CREATE TABLE IF NOT EXISTS Results(Id INTEGER PRIMARY KEY, Mode TEXT, Timestamp INTEGER, TimeS REAL, Input TEXT, FailedAttempts INTEGER, Word TEXT)'
    
    count = @db.get_first_row('SELECT count(*) FROM Results')[0]
    if count == 0 and File.exists?(old_results_file)
      puts "SQLite DB Empty, filling from YAML data."
      old_results = YAML::load(File.read(old_results_file))
      old_results.each do |mode, results|
        puts "Storing #{results.length} results for #{mode}."
        results.each { |r| record_result(mode, r) }
      end
    end
  end

  def load_results
    stm = @db.prepare 'SELECT Mode, Timestamp, TimeS, Input, FailedAttempts, Word FROM Results'
    results = {}
    stm.execute.each do |r|
      mode = r[0].to_sym
      result = Result.from_raw_data(r[1..-1])
      results[mode] ||= []
      results[mode].push(result)
    end
    results.each {|m,r| p m, r.length}
    results
  end

  def replace_word(mode, input, word)
    stm = @db.prepare 'UPDATE Results SET Word = ? WHERE Mode = ? and Input = ?';
    stm.execute(word, mode, input)
  end

  def record_result(mode, result)
    stm = @db.prepare ('INSERT INTO Results(Mode, Timestamp, TimeS, Input, FailedAttempts, Word) Values(?, ?, ?, ?, ?, ?)')
    stm.execute(mode.to_s, *result.to_raw_data)
  end
end
