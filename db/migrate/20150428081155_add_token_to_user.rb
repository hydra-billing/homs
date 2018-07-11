class AddTokenToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :api_token, :string

    add_index :users, :api_token
  end
end
