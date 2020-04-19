class CreateStats < ActiveRecord::Migration[6.0]
  def change
    create_table :stats do |t|
      t.references :mode, null: false, foreign_key: true
      t.string :stat_type, null: false
      t.timestamps

      t.index [:mode_id, :stat_type], unique: true
    end
  end
end
