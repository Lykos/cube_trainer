class MoveMemoTimeSToModes < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :memo_time_s
    add_column :modes, :memo_time_s, :float
  end
end
