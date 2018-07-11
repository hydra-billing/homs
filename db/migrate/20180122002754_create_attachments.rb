class CreateAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :attachments do |t|
      t.references :order, null: false

      t.string :url, null: false
      t.string :name, null: false
      t.string :type

      t.integer :width
      t.integer :height
      t.integer :crc

      t.timestamps null: false
    end
  end
end
