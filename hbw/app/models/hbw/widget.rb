class HBW::Widget
  class << self
    def entity_type_buttons(entity_type)
      bp_toolbar = config[:bp_toolbar] || {}
      common_buttons = bp_toolbar[:common_buttons] || []
      entity_type_buttons = bp_toolbar[:entity_type_buttons] || {}

      common_buttons + entity_type_buttons.fetch(entity_type.to_sym, [])
    end
  end

  class_attribute :config, instance_writer: false
  class_attribute :adapter_class
  delegate :config, to: :'self.class'

  extend Forwardable
  def_delegators :@adapter, :task_list, :entity_task_list,
                 :form, :submit, :users, :users_lookup, :user_exist?

  def initialize
    @adapter = HBW.container[:adapter_class].new(
      entity_code_key: config[:entity_code_key])
  end

  def bp_buttons(entity_identifier, entity_type)
    return [] if @adapter.bp_running?(entity_identifier)

    self.class.entity_type_buttons(entity_type).map do |button_params|
      button_params.slice(*%i(name title class fa_class bp_code))
    end
  end

  def start_bp(user_identifier, bp_code, entity_code)
    bp_code && @adapter.start_process(bp_code,
                                      user_identifier,
                                      entity_code)
  end
end
