class MakeLastMiddleNamesCompanyDepartmentOfUserNotNull < ActiveRecord::Migration
  def up
    undefined = ''
    User.all.map do |user|
      user.update_attributes({
        last_name:   user.last_name   || undefined,
        middle_name: user.middle_name || undefined,
        company:     user.company     || undefined,
        department:  user.department  || undefined
      })
    end

    change_column :users, :name,        :string, null: false
    change_column :users, :middle_name, :string, null: false
    change_column :users, :last_name,   :string, null: false
    change_column :users, :company,     :string, null: false
    change_column :users, :department,  :string, null: false
  end

  def down
    change_column :users, :name,        :string
    change_column :users, :middle_name, :string
    change_column :users, :last_name,   :string
    change_column :users, :company,     :string
    change_column :users, :department,  :string
  end
end
