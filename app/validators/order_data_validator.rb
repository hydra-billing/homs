# Checks record.data to conform record_type.fields definition

class OrderDataValidator < ActiveModel::Validator
  def validate(record)
    fds = record.field_definition_set

    if fds.valid?
      validate_order_data(record, fds)
    else
      handle_invalid_fields_definition(record)
    end
  end

  private

  def validate_order_data(record, fds)
    fds.validate_value(:data, record.data)
    record.errors.add(:data, fds.errors) unless fds.errors.empty?

    log_validation_warnings(record) unless record.errors.empty?
  end

  def handle_invalid_fields_definition(record)
    record.errors.add(:data, :fields_definition_invalid)
    log_fatal_fields_error(record)
  end

  def log_validation_warnings(record)
    record.logger.warn do
      "Warning: Order data=#{record.data} " \
        "with fields definition=#{record.fields} " \
        "produced errors=#{record.errors.messages} " \
        'on validation'
    end
  end

  def log_fatal_fields_error(record)
    record.logger.fatal do
      'Fatal Error: OrderType with ' \
        "id=#{record.order_type.id} has invalid " \
        ":fields  attribute value: #{record.fields}"
    end
  end
end
