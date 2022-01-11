class SpreadsheetIdUnique < ActiveRecord::Migration[6.1]
  def change
    change_table :alg_spreadsheets do |t|
      t.index :spreadsheet_id, unique: true
    end
  end
end
