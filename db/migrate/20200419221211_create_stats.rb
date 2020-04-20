class CreateStats < ActiveRecord::Migration[6.0]
  def change
    create_table :stats do |t|
      t.references :mode, null: false, foreign_key: true
      t.string :stat_type, null: false
      t.integer :index, null: false
      t.timestamps

      t.index [:mode_id, :stat_type], unique: true
      t.index [:mode_id, :index], unique: true

      default_scope { order(index: :asc) }
    end
  end
end
