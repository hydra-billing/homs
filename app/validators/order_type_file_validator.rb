class OrderTypeFileValidator < ActiveModel::Validator
  include CustomFields::HashValidationMethods
  include CustomFields::HasErrors

  # Checks record.hash_from_file
  # 1. it should contain a hash
  # 2. the hash should have :order_type key with hash value
  # 3. the hash[:order_type] should have :fields key with  hash value
  # 4. the hash[:order_type] should have :code key with string value
  # 5. CustomFields::FieldDefSet.new(hash) should be valid
  def validate(record)
    hash = record.hash_from_file
    self.errors = {}

    if validate_order_type_structure(hash)
      validate_field_definitions(hash)
      validate_required_fields(hash)
    end

    add_errors_to_record(record) unless errors.empty?
  end

  private

  def validate_order_type_structure(hash)
    should_have_key?(:order_type, in: hash, as: Hash)
  end

  def validate_field_definitions(hash)
    if should_have_key?(:fields, in: hash[:order_type], as: Hash)
      fds = CustomFields::OrderTypeFieldDefSet.new(hash[:order_type][:fields])
      errors.merge!(fds.errors)
    end
  end

  def validate_required_fields(hash)
    should_have_key?(:code, in: hash[:order_type], as: String)
    should_have_key?(:name, in: hash[:order_type], as: String)
  end

  def add_errors_to_record(record)
    record.errors.add(:file, errors.values.flatten)
  end
end
