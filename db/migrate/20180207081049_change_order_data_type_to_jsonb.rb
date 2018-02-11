class ChangeOrderDataTypeToJsonb < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up   { change_column :orders, :data, 'jsonb using cast(data as jsonb)' }
      dir.down { change_column :orders, :data, 'json using cast(data as json)' }
    end
  end
end
