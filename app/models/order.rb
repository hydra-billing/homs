class Order < ActiveRecord::Base
  class << self
    def id_from_code(code)
      select(:id, :order_type_id).find_by(code: code).try(:id)
    end
  end

  include HasSequencedColumn
  has_sequenced_column :code

  belongs_to :order_type
  belongs_to :user

  validates :order_type, presence: true
  validates_with OrderDataValidator
  after_validation :coerce_values, if: -> rec { rec.errors.empty? }

  delegate :fields, :field_definition_set, to: :order_type
  delegate :name, :code, :print_form_code, to: :order_type, prefix: true

  default_scope { includes(:order_type).order('created_at DESC') }

  enum state: %i(to_execute in_progress done)

  def user_full_name
    user ? user.full_name : ''
  end

  def self.state_i18n_key(state)
    "orders.states.#{state}"
  end

  def field_def_hash(name)
    order_type.fields[name.intern]
  end

  def order_type_id=(*)
    super.tap { initialize_fields }
  end

  def initialize_fields
    self[:data] = field_definition_set.nil_fields_values
  end

  def data=(hash)
    initialize_fields if data.nil?
    self[:data] = data.merge(hash)
  end

  private

  def coerce_values
    self[:data] = field_definition_set.coerce(data)
  end
end
