#!/usr/bin/ruby
# frozen_string_literal: true

require 'cube_trainer/scraping/expertf2l_scraper'
require 'csv'

csv_string =
  CSV.generate do |csv|
  CubeTrainer::Scraping::ExpertF2lScraper.new.scrape_f2l_algs.each do |note|
    alternate_algs = note[:case_solution].alternative_algs.join(AlgHintParser::ALTERNATIVE_ALG_SEPARATOR)
      csv << [note[:case_description].name, note[:case_solution].best_alg, alternate_algs]
    end
  end

puts csv_string
