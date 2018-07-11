class AddPrintFormCodeToOrderType < ActiveRecord::Migration[4.2]
  def change
    add_column :order_types, :print_form_code, :string
  end
end
