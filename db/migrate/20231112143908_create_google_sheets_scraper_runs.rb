class CreateGoogleSheetsScraperRuns < ActiveRecord::Migration[7.0]
  def change
    create_table :google_sheets_scraper_runs do |t|

      t.timestamps
    end
  end
end
