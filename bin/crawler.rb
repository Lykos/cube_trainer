#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/wca/crawler'
require 'cube_trainer/wca/export_parser'

def count_filtered(results)
  results.map { |c| c[:values].count { |r| r.time_centis && r.time_centis % 100 == 73 } }.reduce(:+)
end

crawler = CubeTrainer::WCA::Crawler.new
filename = crawler.download_latest_file
parser = CubeTrainer::WCA::ExportParser.parse(filename)
extractor = CubeTrainer::WCA::StatsExtractor.new(parser)
puts extractor.nemeses('2016BROD01')
