# Checks record.data to conform record_type.fields definition

class OrderDataValidator < ActiveModel::Validator
  def validate(record)
    fds = record.field_definition_set
    if fds.valid?
      fds.validate_value(:data, record.data)
      record.errors.add(:data, fds.errors) unless fds.errors.empty?
      unless record.errors.empty?
        record.logger.warn do
          "Warning: Order data=#{record.data}"\
            " with fields definition=#{record.fields}"\
            " produced errors=#{record.errors.messages}"\
            ' on validation'
        end
      end
    else
      record.errors.add(:data, :fields_definition_invalid)
      record.logger.fatal do
        'Fatal Error: OrderType with'\
          " id=#{record.order_type.id} has invalid"\
          " :fields  attribute value: #{record.fields}"
      end
    end
  end
end
