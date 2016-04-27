class ChangeOrderTypeActiveDefault < ActiveRecord::Migration
  def up
    change_column_default :order_types, :active, false
  end

  def down
    change_column_default :order_types, :active, true
  end
end
