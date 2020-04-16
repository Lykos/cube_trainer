class RemoveUserIdIndex < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        remove_index :achievement_grants, :user_id
        add_index :achievement_grants, :user_id, unique: false
      end
      dir.down do
        remove_index :achievement_grants, :user_id
        add_index :achievement_grants, :user_id, unique: true
      end
    end
  end
end
