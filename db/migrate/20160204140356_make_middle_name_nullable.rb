class MakeMiddleNameNullable < ActiveRecord::Migration
  def change
    change_column_null :users, :middle_name, true
  end
end
