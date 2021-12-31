class AddCaseSetToTrainingSessions < ActiveRecord::Migration[6.1]
  def change
    add_column :training_sessions, :case_set, :string
  end
end
