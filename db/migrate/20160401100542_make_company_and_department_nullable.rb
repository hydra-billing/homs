class MakeCompanyAndDepartmentNullable < ActiveRecord::Migration[4.2]
  def change
    change_column_null :users, :company,    true
    change_column_null :users, :department, true
  end
end
