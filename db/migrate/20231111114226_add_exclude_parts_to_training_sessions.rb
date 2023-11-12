class AddExcludePartsToTrainingSessions < ActiveRecord::Migration[7.0]
  def change
    add_column :training_sessions, :exclude_parts, :string
  end
end
