class FixIndicesAndConstraints < ActiveRecord::Migration[6.0]
  def change
    # download states
    change_column_null :download_states, :model, false
    remove_column :download_states, :timestamps, :string

    # inputs
    change_column_null :inputs, :input_representation, false
    remove_column :inputs, :timestamps, :string
    remove_index :inputs, :old_user_id

    # modes
    change_column_null :modes, :user_id, false
    change_column_null :modes, :name, false
    change_column_default :modes, :known, from: nil, to: false
    change_column_null :modes, :known, false
    change_column_null :modes, :mode_type, false
    change_column_null :modes, :show_input_mode, false
    remove_index :modes, [:user_id, :name]

    # results
    remove_index :results, :created_at
    remove_index :results, [:old_hostname, :old_user_id, :created_at]
    remove_index :results, [:old_mode, :old_user_id]
    remove_index :results, [:old_user_id]
    remove_index :results, [:uploaded_at]

    # users
    change_column_null :users, :admin, false

    # foreign keys
    add_foreign_key :modes, :users
  end
end
