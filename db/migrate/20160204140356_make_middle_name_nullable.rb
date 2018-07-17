class MakeMiddleNameNullable < ActiveRecord::Migration[4.2]
  def change
    change_column_null :users, :middle_name, true
  end
end
