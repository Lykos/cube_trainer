class AddCaseSetToAlgSets < ActiveRecord::Migration[6.1]
  def change
    add_column :alg_sets, :case_set, :string
    change_column_null :alg_sets, :training_session_type, true
  end
end
