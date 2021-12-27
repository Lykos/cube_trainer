class CreateAlgSets < ActiveRecord::Migration[6.0]
  def change
    create_table :alg_spreadsheets do |t|
      t.string :owner, null: false
      t.string :spreadsheet_id, null: false
    end

    create_table :alg_sets do |t|
      t.references :alg_spreadsheet, null: false, foreign_key: true
      t.string :sheet_title, null: false
      t.string :mode_type, null: false
      t.string :buffer

      t.timestamps
    end

    create_table :algs do |t|
      t.references :alg_set, null: false, foreign_key: true
      t.string :case_key, null: false
      t.text :alg, null: false
      t.boolean :is_fixed, default: false, null: false

      t.timestamps
    end
  end
end
