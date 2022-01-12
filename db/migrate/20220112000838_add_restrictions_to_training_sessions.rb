class AddRestrictionsToTrainingSessions < ActiveRecord::Migration[6.1]
  def change
    add_column :training_sessions, :exclude_alg_holes, :boolean
    add_column :training_sessions, :exclude_algless_parts, :boolean
  end
end
