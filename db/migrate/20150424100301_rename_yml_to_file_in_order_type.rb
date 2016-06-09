class RenameYMLToFileInOrderType < ActiveRecord::Migration
  def up
    rename_column :order_types, :yml, :file
  end

  def down
    rename_column :order_types, :file, :yml
  end
end
