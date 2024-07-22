class CreateOrders < ActiveRecord::Migration[4.2]
  def change
    create_table :orders do |t|
      # Тип заказа
      t.references :order_type, null: false
      # Ответственный пользователь Заказницы
      t.references :user

      # Код заказа
      t.string :code, null: false
      # Внешний код заказа (для интеграции)
      t.string :ext_code

      # Идентификатор экземпляра БП заказа
      t.string :bp_id
      # Состояние БП по заказу
      t.string :bp_state

      # Состояние заказа (Справочник - новый, в работе, исполнен)
      t.integer :state, default: 0

      # Дата исполнения
      t.timestamp :done_at

      # Признак архивации
      t.boolean :archived, default: false

      # Данные заказа - настраиваемые столбцы
      t.json :data

      t.timestamps
    end
  end
end
