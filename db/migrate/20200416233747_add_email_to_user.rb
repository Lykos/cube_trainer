class AddEmailToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :email, :string, index: { unique: true }
    reversible do |dir|
      dir.up do
        User.all.each do |user|
          if user.name == 'bernhard'
            user.email = 'bernhard.brodowsky@gmail.com'
          else
            user.email = "#{user.name}@fake.com"
          end
          user.save!
        end
      end
    end
    change_column_null :users, :email, false
  end
end
