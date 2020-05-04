class AddModeIdToInputs < ActiveRecord::Migration[6.0]
  class Input < ApplicationRecord
    has_one :result, dependent: :destroy
  end

  def change
    rename_column :inputs, :mode, :old_mode
    rename_column :inputs, :user_id, :old_user_id
    add_reference :inputs, :mode, index: true, foreign_key: true
    reversible do |dir|
      dir.up do 
        Input.destroy_all
      end
      dir.down do
        # Nothing. The added data gets removed by the schema changes.
      end
    end
    change_column_null :inputs, :mode_id, false
    change_column_null :inputs, :old_mode, true
    change_column_null :inputs, :old_user_id, true
  end
end
