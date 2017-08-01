#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'wca_crawler'
require 'wca_export_reader'

crawler = WCACrawler.new
filename = crawler.get_latest_file
reader = WCAExportReader.new(filename)
puts reader.nemeses('2016BROD01')
