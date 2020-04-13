class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :text
      t.boolean :read, null: false, default: false

      t.timestamps
    end
  end
end
