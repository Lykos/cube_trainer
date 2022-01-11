class RemoveCaseSetFromAlgSets < ActiveRecord::Migration[6.1]
  def change
    remove_column :training_sessions, :case_set, :string
  end
end
