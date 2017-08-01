#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'wca_crawler'

crawler = WCACrawler.new

puts crawler.get_latest_file
