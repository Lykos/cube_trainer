#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/wca/crawler'
require 'cube_trainer/wca/export_reader'

def count_filtered(results)
  results.map { |c| c[:values].count { |r| r.time_centis && r.time_centis % 100 == 73 } }.reduce(:+)
end

crawler = CubeTrainer::WCA::Crawler.new
filename = crawler.download_latest_file
reader = CubeTrainer::WCA::ExportReader.new(filename)
puts reader.nemeses('2016BROD01')
puts "2017: #{count_filtered(reader.results.select { |c| reader.competitions[c[:competitionid]][:startdate].year == 2017 })}"
puts "2016MORA24: #{count_filtered(reader.results.select { |c| c[:personid] == '2016MORA24' })}"
puts "2016COSS01: #{count_filtered(reader.results.select { |c| c[:personid] == '2016COSS01' })}"
puts "2008: #{count_filtered(reader.results.select { |c| reader.competitions[c[:competitionid]][:startdate].year == 2008 })}"
puts "CH: #{count_filtered(reader.results.select { |c| reader.competitions[c[:competitionid]][:countryid] == 'Switzerland' })}"
puts "Albert You: #{count_filtered(reader.results.select { |c| c[:personid] == '2011YOUA01' })}"
puts "3x3: #{count_filtered(reader.results.select { |c| c[:eventid] == '333' })}"
puts "Danish open: #{count_filtered(reader.results.select { |c| c[:competitionid] == 'DanishOpen2015' })}"
