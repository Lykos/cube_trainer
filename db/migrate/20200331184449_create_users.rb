class CreateUsers < ActiveRecord::Migration[6.0]
  class User < ApplicationRecord
    has_secure_password
  end

  class CubeTrainerTrainingResult < ApplicationRecord
  end

  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    user = nil
    if CubeTrainerTrainingResult.exists?
      reversible do |dir|
        dir.up do
          User.reset_column_information
          user =
            User.create!(
              name: 'result_owner',
              password: OsHelper.default_password,
              password_confirmation: OsHelper.default_password
            )
        end
        dir.down do
          # Nothing. The added data gets removed by the schema changes.
        end
      end
    end

    add_column :cube_trainer_training_results, :user_id, :integer, default: user&.id, null: false
    change_column_default :cube_trainer_training_results, :user_id, from: user.id, to: nil if user
    add_index :cube_trainer_training_results, :user_id

    add_column :cube_trainer_training_inputs, :user_id, :integer, default: user&.id, null: false
    change_column_default :cube_trainer_training_inputs, :user_id, from: user.id, to: nil if user
    add_index :cube_trainer_training_inputs, :user_id
  end
end
