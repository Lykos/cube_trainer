class DropNotifications < ActiveRecord::Migration[6.0]
  def change
    drop_table :notifications, if_exists: true do |t|
      t.bigint :user_id, null: false
      t.string :title
      t.text :message
      t.boolean :read
      t.datetime :created_at, precision: 6, null: false
      t.datetime :updated_at, precision: 6, null: false
      t.index [:user_id], name: :index_notifications_on_user_id
    end
  end
end
