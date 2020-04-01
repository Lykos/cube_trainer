class MoveModels < ActiveRecord::Migration[6.0]
  def change
    rename_table :cube_trainer_training_download_states, :download_states
    rename_table :cube_trainer_training_inputs, :inputs
    rename_table :cube_trainer_training_results, :results
  end
end
