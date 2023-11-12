class AddAlgSpreadsheetToSheetRuns < ActiveRecord::Migration[7.0]
  def change
    add_reference :sheet_runs, :alg_spreadsheet, null: false, foreign_key: true
  end
end
