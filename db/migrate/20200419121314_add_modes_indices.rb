class AddModesIndices < ActiveRecord::Migration[6.0]
  def change
    add_index :modes, :user_id
    add_index :modes, [:user_id, :name], unique: true
  end
end
