class AddPrintFormCodeToOrderType < ActiveRecord::Migration
  def change
    add_column :order_types, :print_form_code, :string
  end
end
