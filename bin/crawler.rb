#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/wca_crawler'
require 'cube_trainer/wca_export_reader'

include CubeTrainer

def count_filtered(results)
  results.map { |c| c[:values].count { |r| r.time_centis && r.time_centis % 100 == 73 } }.reduce(:+)
end

crawler = WCACrawler.new
filename = crawler.get_latest_file
reader = WCAExportReader.new(filename)
# puts reader.nemeses('2017MINA04')
puts "2017: #{count_filtered(reader.results.select { |c| reader.competitions[c[:competitionid]][:startdate].year == 2017 })}"
puts "2016MORA24: #{count_filtered(reader.results.select { |c| c[:personid] == '2016MORA24' })}"
puts "2016COSS01: #{count_filtered(reader.results.select { |c| c[:personid] == '2016COSS01' })}"
puts "2008: #{count_filtered(reader.results.select { |c| reader.competitions[c[:competitionid]][:startdate].year == 2008 })}"
puts "CH: #{count_filtered(reader.results.select { |c| reader.competitions[c[:competitionid]][:countryid] == 'Switzerland' })}"
puts "Albert You: #{count_filtered(reader.results.select { |c| c[:personid] == '2011YOUA01' })}"
puts "3x3: #{count_filtered(reader.results.select { |c| c[:eventid] == '333' })}"
puts "Danish open: #{count_filtered(reader.results.select { |c| c[:competitionid] == 'DanishOpen2015' })}"
