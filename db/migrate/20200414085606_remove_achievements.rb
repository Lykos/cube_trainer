class RemoveAchievements < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        remove_index :achievement_grants, [:user_id, :achievement_id]
      end
      dir.down do
        add_index :achievement_grants, [:user_id, :achievement_id], unique: true
      end
    end
    remove_reference :achievement_grants, :achievement, null: false, index: { unique: true }, foreign_key: true
    add_column :achievement_grants, :achievement, :string, null: false
    add_index :achievement_grants, [:user_id, :achievement], unique: true
    drop_table :achievements do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :achievement_type, null: false, index: true
      t.integer :param
      t.timestamps
    end
  end
end
