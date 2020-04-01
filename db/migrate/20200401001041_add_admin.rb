class AddAdmin < ActiveRecord::Migration[6.0]
  class User < ApplicationRecord
  end

  def change
    add_column :users, :admin, :boolean, default: false
    reversible do |dir|
      dir.up do
        User.reset_column_information
        user = User.find_by(name: 'bernhard')
        user.admin = true
        # Lol, don't worry, this is not the prod password, but I needed to bootstrap users
        # somehow.
        user.password = 'abc123'
        user.password_confirmation = 'abc123'
        user.save!
      end
      dir.down do
        # Nothing. The added data gets removed by the schema changes.
      end
    end
  end
end
