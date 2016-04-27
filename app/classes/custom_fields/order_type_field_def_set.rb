module CustomFields
  class OrderTypeFieldDefSet < FieldDefSet
    private

    def field_def_class
      OrderTypeFieldDef
    end
  end
end
