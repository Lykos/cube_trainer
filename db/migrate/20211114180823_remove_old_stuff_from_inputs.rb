class RemoveOldStuffFromInputs < ActiveRecord::Migration[6.0]
  def change
    remove_column :inputs, :old_mode, :text
    remove_column :inputs, :old_user_id, :integer
  end
end
