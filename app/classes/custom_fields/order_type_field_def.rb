module CustomFields
  class OrderTypeFieldDef < FieldDef
    def boolean_fields
      []
    end

    def string_fields
      [:name, :type, :label]
    end
  end
end
