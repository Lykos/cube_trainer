class CreateModeUsages < ActiveRecord::Migration[6.0]
  def change
    create_table :mode_usages do |t|
      t.references :mode, null: false, foreign_key: true
      t.references :used_mode, null: false, foreign_key: { to_table: :modes }
    end
  end
end
