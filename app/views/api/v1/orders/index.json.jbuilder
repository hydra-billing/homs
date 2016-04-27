json.orders do
  json.partial! partial: 'api/v1/orders/order',
                collection: @orders, as: :order
end
