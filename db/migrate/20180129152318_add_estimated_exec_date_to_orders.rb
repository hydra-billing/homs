class AddEstimatedExecDateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :estimated_exec_date, :datetime
  end
end
