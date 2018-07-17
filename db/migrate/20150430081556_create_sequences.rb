class CreateSequences < ActiveRecord::Migration[4.2]
  def change
    create_table :sequences do |t|
      t.string :name, null: false, unique: true
      t.string :prefix, null: false, unique: true
      t.integer :start, default: 1
    end

    add_index :sequences, :name
  end
end
