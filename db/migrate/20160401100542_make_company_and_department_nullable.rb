class MakeCompanyAndDepartmentNullable < ActiveRecord::Migration
  def change
    change_column_null :users, :company,    true
    change_column_null :users, :department, true
  end
end
