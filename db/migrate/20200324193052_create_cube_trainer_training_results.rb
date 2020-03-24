class CreateCubeTrainerTrainingResults < ActiveRecord::Migration[6.0]
  def change
    create_table :cube_trainer_training_results do |t|
      t.text :mode
      t.float :time_s
      t.text :raw_input_representation
      t.integer :failed_attempts
      t.text :word
      t.boolean :success
      t.integer :num_hints

      t.timestamps
    end
    add_index :cube_trainer_training_results, :mode
  end
end
