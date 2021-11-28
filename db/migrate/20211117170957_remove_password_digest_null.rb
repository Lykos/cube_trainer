class RemovePasswordDigestNull < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :password_digest, null: false, default: ''
  end
end
