class RemoveConfirmedColumnsFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :admin_confirmed, :boolean, default: false
    remove_column :users, :email_confirmed, :boolean, default: false
  end
end
