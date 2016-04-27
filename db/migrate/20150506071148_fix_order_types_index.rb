class FixOrderTypesIndex < ActiveRecord::Migration
  def up
    remove_index :order_types, [:active, :code]
    add_index    :order_types, [:code, :active]
  end

  def down
    remove_index :order_types, [:code, :active]
    add_index    :order_types, [:active, :code]
  end
end
