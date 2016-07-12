class OrderType < ActiveRecord::Base
  class << self
    def lookup(q)
      s = q.mb_chars.downcase.to_s

      active.where('lower(name) like ?', "%#{s}%")
        .select('id, name')
        .order(name: :asc)
        .map { |e| { id: e.id, text: e.name } }
    end

    def id_from_code(code)
      active.select(:id).find_by(code: code).try(:id)
    end
  end

  include FileContainsYaml

  validates_with OrderTypeFileValidator

  has_many :orders
  before_destroy :check_for_orders

  serialize :fields

  scope :active, -> { where(active: true).order(name: :asc) }
  scope :code, ->(code) { where(active: true, code: code) }

  def initialize(*)
    super

    parse_file
  end

  def save_if_differs!
    last_one = self.class.code(code).last
    return false if self == last_one
    save!
  end

  def ==(other)
    other && other.code == code && other.fields == fields
  end

  def activate
    last_one = self.class.code(code).last
    transaction do
      last_one.update_column(:active, false) if last_one
      update_column(:active, true)
    end
  end

  def nil_fields_values
    field_definition_set.nil_fields_values
  end

  def field_definition_set
    CustomFields::FieldDefSet.new(fields)
  end

  def make_invisile
    update_attribute(:active, false)
  end

  private

  def parse_file
    OrderTypeFileValidator.new.validate self
    return unless errors.empty?

    self.fields          = hash_from_file[:order_type][:fields]
    self.code            = hash_from_file[:order_type][:code]
    self.name            = hash_from_file[:order_type][:name]
    self.print_form_code = hash_from_file[:order_type][:print_form_code]
  end

  def check_for_orders
    if orders.count > 0
      errors.add(:base, :cannot_delete_as_orders_exist)
      false
    else
      true
    end
  end
end
