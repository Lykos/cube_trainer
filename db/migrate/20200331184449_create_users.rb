class CreateUsers < ActiveRecord::Migration[6.0]
  def up
    create_table :users do |t|
      t.string :name, null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    # Lol, don't worry, this is not the prod password, but I needed to bootstrap users
    # somehow.
    user = User.new(name: 'bernhard', password: 'abc123', password_confirmation: 'abc123')
    user.save!

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
