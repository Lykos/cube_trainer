 require 'cube_trainer/sheet_scraping/google_sheets_scraper'

 class GoogleSheetsScraperWorker
   include Sidekiq::Worker

   # This is scheduled regularly anyway, so we don't need to
   # keep track of failed jobs and retry them later.
   sidekiq_options retry: 0, dead: false

   def perform
     CubeTrainer::SheetScraping::GoogleSheetsScraper.new.run
   end
end
