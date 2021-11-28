class DeviseTokenAuthChangeUsers < ActiveRecord::Migration[6.0]
  class User < ApplicationRecord
  end

  def change
    change_table :users do |t|
      ## Required
      t.string :provider # We have to add `null: false` below
      t.string :uid # We have to add `null: false` below

      ## Database authenticatable
      t.string :encrypted_password # We have to add `null: false` below

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.boolean  :allow_password_change, default: false

      ## Rememberable
      t.datetime :remember_created_at

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      ## User Info
      # We already have our own user info
      # t.string :name
      # t.string :nickname
      # t.string :image
      # t.string :email

      ## Tokens
      t.json :tokens
    end

    reversible do |change|
      change.up do
        User.reset_column_information
        User.all.each do |user|
          user.update(provider: 'email', encrypted_password: '', uid: user.email)
        end
      end
    end

    change_column_null :users, :provider, false
    change_column_null :users, :uid, false
    change_column_null :users, :encrypted_password, false

    # already exists
    # add_index :users, :email,                unique: true
    add_index :users, [:uid, :provider],     unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :unlock_token,         unique: true
  end
end
