class RemoveHostnameFromInputs < ActiveRecord::Migration[6.0]
  def change
    remove_column :inputs, :hostname, :string
  end
end
