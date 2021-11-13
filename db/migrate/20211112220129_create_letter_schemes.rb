class CreateLetterSchemes < ActiveRecord::Migration[6.0]
  def change
    create_table :letter_schemes do |t|
      t.integer :user_id, null: false
      t.string :name, null: false

      t.timestamps
      t.index [:user_id, :name], name: :index_letter_schemes_on_user_id_and_name, unique: true
      t.index [:user_id], name: :index_letter_schemes_on_user_id
    end
  end
end
