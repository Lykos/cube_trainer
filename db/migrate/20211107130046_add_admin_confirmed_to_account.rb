class AddAdminConfirmedToAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :admin_confirmed, :boolean, default: false
  end
end
