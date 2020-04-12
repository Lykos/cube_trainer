class CreateAchievements < ActiveRecord::Migration[6.0]
  def change
    create_table :achievements do |t|
      t.string :name, index: { unique: true }, null: false
      t.string :achievement_type, index: true, null: false
      t.integer :param

      t.timestamps
    end
  end
end
