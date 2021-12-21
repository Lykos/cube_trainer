# frozen_string_literal: true

desc 'Scrape algs sheets from Google sheets'
task scrape_sheets: :environment do
  require 'cube_trainer/sheet_scraping/google_sheets_scraper'

  Rails.logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger.level = 1
  CubeTrainer::SheetScraping::GoogleSheetsScraper.new.run
end
