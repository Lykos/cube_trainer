# frozen_string_literal: true

require 'cube_trainer/sheet_scraping/google_sheets_scraper'

# Worker that scrapes alg sets from Google sheets.
class GoogleSheetsScrapeWorker
  include Sidekiq::Worker

  # This is scheduled regularly anyway, so we don't need to
  # keep track of failed jobs and retry them later.
  sidekiq_options retry: 0, dead: false

  def perform
    CubeTrainer::SheetScraping::GoogleSheetsScraper.new.run
  end
end
