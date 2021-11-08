class AddMemoTimeS < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :memo_time_s, :integer
  end
end
