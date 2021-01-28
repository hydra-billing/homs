module ProfilesHelper
  def common_fields
    {
      code:                {label: Order.human_attribute_name(:code),                type: :link,     show: true},
      order_type_code:     {label: Order.human_attribute_name(:order_type_code),     type: :string,   show: true},
      state:               {label: Order.human_attribute_name(:state),               type: :state,    show: true},
      created_at:          {label: Order.human_attribute_name(:created_at),          type: :datetime, show: true},
      user:                {label: Order.human_attribute_name(:user),                type: :string,   show: true},
      ext_code:            {label: t('orders.index.ext_code'),                       type: :string,   show: true},
      archived:            {label: t('orders.index.archived'),                       type: :boolean,  show: true},
      estimated_exec_date: {label: Order.human_attribute_name(:estimated_exec_date), type: :datetime, show: true}
    }
  end

  def common_profile
    {data: common_fields}
  end

  def consist_profile_data(order_type, data)
    actual_fields = common_fields.merge(order_type.fields)

    actual_fields.each_with_object({}) do |(key, value), fields|
      fields[key] = if data[key]
                      value.merge(show: data[key]['show'])
                    else
                      value.merge(show: false)
                    end
    end
  end

  def custom_profile(order_type)
    profile = Profile.by_order_type_and_user(order_type.id, current_user.id)

    if profile
      profile.data = consist_profile_data(order_type, profile.data.with_indifferent_access)
      profile
    else
      Profile.new(order_type_id: order_type.id,
                  user_id:       current_user.id,
                  data:          consist_profile_data(order_type, common_fields.with_indifferent_access))
    end
  end
end
