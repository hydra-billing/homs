class CreateOrderTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :order_types do |t|
      t.string :code, null: false
      t.text :yml, null: false
      t.text :fields, null: false
      t.boolean :active, default: true

      t.timestamps null: false
    end

    add_index :order_types, [:code, :created_at], unique: true
    add_index :order_types, [:active, :code]
  end
end
