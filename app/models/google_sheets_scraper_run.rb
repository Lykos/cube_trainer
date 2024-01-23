# frozen_string_literal: true

# Information about one run of the Google sheets scraper.
class GoogleSheetsScraperRun < ApplicationRecord
  has_many :sheet_runs, dependent: :destroy
end
