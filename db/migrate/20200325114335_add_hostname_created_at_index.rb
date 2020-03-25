class AddHostnameCreatedAtIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :cube_trainer_training_results, [:hostname, :created_at], unique: true
  end
end
