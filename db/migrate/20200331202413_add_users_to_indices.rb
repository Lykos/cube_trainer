class AddUsersToIndices < ActiveRecord::Migration[6.0]
  def change
    remove_index :results, name: 'index_results_on_hostname_and_created_at'
    remove_index :results, name: 'index_results_on_mode'
    add_index :results, [:hostname, :user, :created_at], unique: true
    add_index :results, [:mode, :user]
  end
end
