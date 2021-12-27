class CreateAlgOverrides < ActiveRecord::Migration[6.0]
  def change
    create_table :alg_overrides do |t|
      t.references :mode, null: false, foreign_key: true
      t.string :case_key, null: false
      t.string :alg, null: false

      t.timestamps
    end
  end
end
