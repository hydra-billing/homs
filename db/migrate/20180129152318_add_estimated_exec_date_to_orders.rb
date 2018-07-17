class AddEstimatedExecDateToOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :orders, :estimated_exec_date, :datetime
  end
end
