class CreateColorSchemes < ActiveRecord::Migration[6.0]
  def change
    create_table :color_schemes do |t|
      t.integer :user_id, null: false
      t.string :U
      t.string :F
      t.string :R
      t.string :B
      t.string :L
      t.string :D

      t.timestamps
      t.index [:user_id], name: 'index_color_schemes_on_user_id'
    end

    add_foreign_key 'color_schemes', 'users'
  end
end
