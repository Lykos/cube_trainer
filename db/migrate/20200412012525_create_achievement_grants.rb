class CreateAchievementGrants < ActiveRecord::Migration[6.0]
  def change
    create_table :achievement_grants do |t|
      t.references :achievement, null: false, index: { unique: true }, foreign_key: true
      t.references :user, null: false, index: { unique: true }, foreign_key: true
      t.index [:user_id, :achievement_id], unique: true

      t.timestamps
    end
  end
end
