class AddDirectoryToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :directory, :string, null: false, default: :internal
  end
end
