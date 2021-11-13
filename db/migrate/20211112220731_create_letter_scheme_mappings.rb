class CreateLetterSchemeMappings < ActiveRecord::Migration[6.0]
  def change
    create_table :letter_scheme_mappings do |t|
      t.integer :letter_scheme_id, null: false
      t.string :part, null: false
      t.string :letter, null: false

      t.timestamps
      t.index [:letter_scheme_id, :part], name: :index_letter_scheme_mappings_on_letter_scheme_id_and_part, unique: true
      t.index [:letter_scheme_id], name: :index_letter_scheme_mappings_on_letter_scheme_id
    end
  end
end
