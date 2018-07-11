class AddIndexForOrderCode < ActiveRecord::Migration[4.2]
  def change
    add_index :orders, :code
  end
end
