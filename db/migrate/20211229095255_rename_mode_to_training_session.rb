class RenameModeToTrainingSession < ActiveRecord::Migration[6.1]
  def change
    rename_column :alg_overrides, :mode_id, :training_session_id
    rename_column :alg_sets, :mode_type, :training_session_type
    rename_column :mode_usages, :mode_id, :training_session_id
    rename_column :mode_usages, :used_mode_id, :used_training_session_id
    rename_column :modes, :mode_type, :training_session_type
    rename_column :results, :mode_id, :training_session_id
    rename_column :stats, :mode_id, :training_session_id

    rename_table :modes, :training_sessions
    rename_table :mode_usages, :training_session_usages
  end
end
