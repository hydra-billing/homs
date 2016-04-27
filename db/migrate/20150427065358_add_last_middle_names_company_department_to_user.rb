class AddLastMiddleNamesCompanyDepartmentToUser < ActiveRecord::Migration
  def change
    add_column :users, :middle_name, :string
    add_column :users, :last_name,   :string
    add_column :users, :company,     :string
    add_column :users, :department,  :string
  end
end
