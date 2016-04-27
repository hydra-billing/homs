class AddNameToOrderTypes < ActiveRecord::Migration
  def change
    add_column :order_types, :name, :string, null: true

    connection.execute('update order_types set name = code')

    change_column_null :order_types, :name, false
  end
end
