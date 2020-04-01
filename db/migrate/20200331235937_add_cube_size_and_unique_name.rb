class AddCubeSizeAndUniqueName < ActiveRecord::Migration[6.0]
  def change
    add_column :modes, :cube_size, :integer
    add_index :modes, [:user_id, :name], unique: true
  end
end
