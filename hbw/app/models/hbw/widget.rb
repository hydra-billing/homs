class HBW::Widget
  class << self
    def entity_type_buttons(entity_type, entity_class)
      bp_toolbar = config[:entities].fetch(entity_class)[:bp_toolbar] || {}
      common_buttons = bp_toolbar[:common_buttons] || []
      entity_type_buttons = bp_toolbar[:entity_type_buttons] || {}

      common_buttons + entity_type_buttons.fetch(entity_type.to_sym, [])
    end
  end

  class_attribute :config, instance_writer: false

  extend Forwardable

  def_delegators :@adapter, :task_list, :get_task_with_form, :form,
                 :submit, :users, :users_lookup, :user_exist?,
                 :claim_task, :get_task_by_id, :get_form_by_task_id,
                 :get_forms_for_task_list, :cancel_process

  include HBW::Inject[:adapter]

  def bp_buttons(entity_identifier, entity_type, entity_class, current_user_identifier)
    if !@adapter.user_exist?(current_user_identifier)
      {}
    elsif @adapter.bp_running?(entity_identifier, entity_class)
      {buttons: [], bp_running: true}
    else
      buttons = self.class.entity_type_buttons(entity_type, entity_class).map do |button_params|
        button_params.slice(:name, :title, :class, :fa_class, :bp_code)
      end
      {buttons: buttons, bp_running: false}
    end
  end

  def start_bp(user_identifier, bp_code, entity_code, entity_class, initial_variables = {})
    bp_code && @adapter.start_process(bp_code,
                                      user_identifier,
                                      entity_code,
                                      entity_class,
                                      initial_variables)
  end
end
