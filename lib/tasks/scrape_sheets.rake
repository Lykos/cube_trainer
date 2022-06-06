# frozen_string_literal: true

def sheet_filter(args)
  return CubeTrainer::SheetScraping::AllSheetFilter.new unless args[:owner_regexp] || args[:sheet_title_regexp]

  owner_regexp = args[:owner_regexp] ? Regexp.new(args[:owner_regexp]) : /.*/
  sheet_title_regexp = args[:sheet_title_regexp] ? Regexp.new(args[:sheet_title_regexp]) : /.*/

  CubeTrainer::SheetScraping::RegexpSheetFilter.new(
    owner_regexp: owner_regexp,
    sheet_title_regexp: sheet_title_regexp
  )
end

desc 'Scrape algs sheets from Google sheets'
task :scrape_sheets, %i[owner_regexp sheet_title_regexp] => :environment do |_task, args|
  require 'cube_trainer/sheet_scraping/google_sheets_scraper'
  require 'cube_trainer/sheet_scraping/sheet_filter'

  Rails.logger = Logger.new($stdout)
  Rails.logger.level = 1
  CubeTrainer::SheetScraping::GoogleSheetsScraper.new(sheet_filter: sheet_filter(args)).run
end
