class DropDownloadStates < ActiveRecord::Migration[6.0]
  def change
    drop_table :download_states, if_exists: true do |t|
      t.text :model, null: false
      t.datetime :downloaded_at
      t.datetime :created_at, precision: 6, null: false
      t.datetime :updated_at, precision: 6, null: false
      t.index [:model], name: :index_download_states_on_model, unique: true
    end
  end
end
