module Features
  module OrderTypesHelper
    def delete_order_type(order_type_name)
      page.find("a.text-danger[data-confirm=\"Are you sure you want to delete the order type «#{order_type_name}»? Existing orders won't be affected.\"]").click
    end
  end
end
