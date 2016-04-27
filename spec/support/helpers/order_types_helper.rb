module Features
  module OrderTypesHelper
    def delete_order_type(order_type_name)
      page.find("a.text-danger[data-confirm=\"Are you sure you want delete order type «#{order_type_name}»? Existing orders won\'t be affected.\"]").trigger('click')
    end
  end
end
