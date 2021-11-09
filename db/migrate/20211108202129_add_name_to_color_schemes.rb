class AddNameToColorSchemes < ActiveRecord::Migration[6.0]
  def change
    add_column :color_schemes, :name, :string, null: false
    add_index :color_schemes, [:user_id, :name], name: 'index_color_schemes_on_user_id_and_name', unique: true
  end
end
