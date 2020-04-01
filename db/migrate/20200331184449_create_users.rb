class CreateUsers < ActiveRecord::Migration[6.0]
    class User < ApplicationRecord
    end

    def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        User.reset_column_information
        # Lol, don't worry, this is not the prod password,
        # but I needed to bootstrap users somehow.
        user = User.create!(name: 'bernhard', password: 'abc123', password_confirmation: 'abc123')
      end
      dir.down do
        # Nothing. The added data gets removed by the schema changes.
      end
    end

    add_column :cube_trainer_training_results, :user_id, :integer, default: user.id, null: false
    change_column :cube_trainer_training_results, :user_id, :integer, default: nil
    add_index :cube_trainer_training_results, :user_id

    add_column :cube_trainer_training_inputs, :user_id, :integer, default: user.id, null: false
    change_column :cube_trainer_training_inputs, :user_id, :integer, default: nil
    add_index :cube_trainer_training_inputs, :user_id
  end

  def down
    drop_table :users
    remove_column :cube_trainer_training_results, :user_id
    remove_column :cube_trainer_training_inputs, :user_id
  end
end
