class AddEmailConfirmColumnToUsers < ActiveRecord::Migration[6.0]
  class User < ApplicationRecord
  end

  def change
    add_column :users, :email_confirmed, :boolean, default: false
    add_column :users, :confirm_token, :string

    reversible do |change|
      change.up do
        User.all.each do |user|
          user.update(email_confirmed: true) if user.admin_confirmed
        end
      end
    end
  end
end
