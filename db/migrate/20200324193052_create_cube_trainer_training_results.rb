class CreateCubeTrainerTrainingResults < ActiveRecord::Migration[6.0]
  def change
    create_table :cube_trainer_training_results do |t|
      t.text :mode, null: false
      t.float :time_s, null: false
      t.text :raw_input_representation, null: false
      t.integer :failed_attempts, null: false, default: 0
      t.text :word
      t.boolean :success, null: false, default: true
      t.integer :num_hints, null: false, default: 0

      t.timestamps
    end
    add_index :cube_trainer_training_results, :mode
    add_index :cube_trainer_training_results, :created_at
  end
end
