#!/usr/bin/ruby
# frozen_string_literal: true

require 'cube_trainer/scraping/expertf2l_scraper'
require 'csv'

puts CubeTrainer::Scraping::ExpertF2lScraper.new.scrape_f2l_algs
