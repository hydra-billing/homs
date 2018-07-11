class CreateProfiles < ActiveRecord::Migration[4.2]
  def change
    create_table :profiles do |t|
      t.references :user,       index: true, foreign_key: true, null: false
      t.references :order_type, index: true, foreign_key: true, null: false
      t.json :data, null: false

      t.timestamps null: false
    end

    add_index :profiles, [:user_id, :order_type_id], unique: true
  end
end
