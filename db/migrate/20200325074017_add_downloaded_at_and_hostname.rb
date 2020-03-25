class AddUploadedAtAndHostname < ActiveRecord::Migration[6.0]
  def change
    add_column :cube_trainer_training_results, :hostname, :text, default: `hostname`.chomp, null: false
    change_column :cube_trainer_training_results, :hostname, :text, default: nil
    add_column :cube_trainer_training_results, :uploaded_at, :datetime, precision: 6
    add_index :cube_trainer_training_results, :uploaded_at
  end
end
