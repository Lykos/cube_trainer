class RemoveOldStuffFromResults < ActiveRecord::Migration[6.0]
  def change
    remove_column :results, :old_mode, :text
    remove_column :results, :old_input_representation, :text
    remove_column :results, :old_hostname, :text
    remove_column :results, :old_user_id, :integer
  end
end
