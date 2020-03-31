class CreateModes < ActiveRecord::Migration[6.0]
  def change
    create_table :modes do |t|
      t.integer :user_id
      t.string :name
      t.boolean :known
      t.string :type
      t.string :show_input_mode
      t.string :buffer
      t.float :goal_badness

      t.timestamps
    end
  end
end
