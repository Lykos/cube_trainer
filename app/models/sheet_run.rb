# frozen_string_literal: true

# Information about one run of the Google sheets scraper on one spreadsheet.
class SheetRun < ApplicationRecord
  belongs_to :google_sheets_scraper_run
end
