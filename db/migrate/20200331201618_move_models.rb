class MoveModels < ActiveRecord::Migration[6.0]
  def change
    rename_table :cube_trainer_training_download_states, :download_states
    rename_index :download_states, 'index_cube_trainer_training_download_states_on_model', 'index_download_states_on_model'

    rename_table :cube_trainer_training_inputs, :inputs
    rename_index :inputs, 'index_cube_trainer_training_inputs_on_user_id', 'index_inputs_on_user_id'

    rename_table :cube_trainer_training_results, :results
    rename_index :results, 'index_cube_trainer_training_results_on_created_at', 'index_results_on_created_at'
    rename_index :results, 'index_cube_trainer_training_results_on_hostname_and_created_at', 'index_results_on_hostname_and_created_at'
    rename_index :results, 'index_cube_trainer_training_results_on_mode', 'index_results_on_mode'
    rename_index :results, 'index_cube_trainer_training_results_on_uploaded_at', 'index_results_on_uploaded_at'
    rename_index :results, 'index_cube_trainer_training_results_on_user_id', 'index_results_on_user_id'
  end
end
