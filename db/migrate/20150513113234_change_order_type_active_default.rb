class ChangeOrderTypeActiveDefault < ActiveRecord::Migration[4.2]
  def up
    change_column_default :order_types, :active, false
  end

  def down
    change_column_default :order_types, :active, true
  end
end
