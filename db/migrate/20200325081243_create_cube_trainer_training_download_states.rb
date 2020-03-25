class CreateCubeTrainerTrainingDownloadStates < ActiveRecord::Migration[6.0]
  def change
    create_table :cube_trainer_training_download_states do |t|
      t.text :model
      t.datetime :downloaded_at
      t.string :timestamps

      t.timestamps
    end
  end
end
