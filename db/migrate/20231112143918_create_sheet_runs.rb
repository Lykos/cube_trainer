class CreateSheetRuns < ActiveRecord::Migration[7.0]
  def change
    create_table :sheet_runs do |t|
      t.references :google_sheets_scraper_run, null: false, foreign_key: true
      t.integer :updated_algs
      t.integer :new_algs
      t.integer :confirmed_algs
      t.integer :correct_algs
      t.integer :fixed_algs
      t.integer :unfixable_algs
      t.integer :unparseable_algs

      t.timestamps
    end
  end
end
