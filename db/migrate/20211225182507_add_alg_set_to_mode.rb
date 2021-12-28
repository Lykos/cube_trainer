class AddAlgSetToMode < ActiveRecord::Migration[6.0]
  def change
    add_column :modes, :alg_set_id, :integer
    add_foreign_key :modes, :alg_sets
  end
end
