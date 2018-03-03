class AddExternalBlockedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :external, :boolean, default: false, null: false
    add_column :users, :blocked, :boolean, default: false, null: false
  end
end
