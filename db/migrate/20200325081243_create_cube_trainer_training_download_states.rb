class CreateCubeTrainerTrainingDownloadStates < ActiveRecord::Migration[6.0]
  def change
    create_table :cube_trainer_training_download_states do |t|
      t.text :model
      t.datetime :downloaded_at
      t.string :timestamps

      t.timestamps
    end
    add_index :cube_trainer_training_download_states, :model, unique: true
  end
end
