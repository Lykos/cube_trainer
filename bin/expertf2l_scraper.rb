#!/usr/bin/ruby
# frozen_string_literal: true

require 'cube_trainer/scraping/expertf2l_scraper'
require 'csv'

csv_string =
  CSV.generate do |csv|
    CubeTrainer::Scraping::ExpertF2lScraper.new.scrape_f2l_algs.each do |note|
      csv << [note[:case_description].name, note[:best_alg], note[:alternate_algs]]
    end
  end

puts csv_string
