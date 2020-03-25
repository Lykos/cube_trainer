class CreateCubeTrainerTrainingInputs < ActiveRecord::Migration[6.0]
  def change
    create_table :cube_trainer_training_inputs do |t|
      t.text :mode
      t.text :input_representation
      t.string :timestamps

      t.timestamps
    end
  end
end
