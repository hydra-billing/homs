class AddPasswordSaltToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :password_salt, :string
  end
end
