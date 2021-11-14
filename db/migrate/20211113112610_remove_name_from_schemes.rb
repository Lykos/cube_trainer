class RemoveNameFromSchemes < ActiveRecord::Migration[6.0]
  def change
    remove_column :color_schemes, :name, :string
    remove_column :letter_schemes, :name, :string
  end
end
