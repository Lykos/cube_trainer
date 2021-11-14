class MakeSchemeIndicesUnique < ActiveRecord::Migration[6.0]
  def change
    remove_index :color_schemes, column: :user_id, name: :index_color_schemes_on_user_id
    remove_index :letter_schemes, column: :user_id, name: :index_letter_schemes_on_user_id
    add_index :color_schemes, :user_id, unique: true
    add_index :letter_schemes, :user_id, unique: true
    change_column_null :color_schemes, :user_id, false
    change_column_null :letter_schemes, :user_id, false
  end
end
