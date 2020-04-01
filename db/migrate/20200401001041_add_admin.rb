class AddAdmin < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :admin, :boolean, default: false
    user = User.find_by(name: 'bernhard')
    user.admin = true
    # Lol, don't worry, this is not the prod password, but I needed to bootstrap users
    # somehow.
    user.password = 'abc123'
    user.password_confirmation = 'abc123'
    user.save!
  end
end
