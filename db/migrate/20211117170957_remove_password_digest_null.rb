class RemovePasswordDigestNull < ActiveRecord::Migration[6.0]
  class User < ApplicationRecord
  end

  def change
    remove_column :users, :password_digest, null: false, default: ''
  end
end
