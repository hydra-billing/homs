FactoryBot.define do
  factory :order do |order|
    trait :order_vacation_request do
      order.sequence(:order_type) do
        FactoryBot.create(:order_type, :vacation_request)
      end

      ext_code 'ext_code'
      bp_id 'bp_id'
      bp_state 'bp_state'
      state 1
      done_at Time.zone.now
      estimated_exec_date Time.zone.now + 1.day
      archived false
    end

    trait :order_support_request do
      ext_code 'support_ext_code'
      bp_id 'bp_id'
      bp_state 'bp_state'
      state 1
      done_at Time.zone.now
      estimated_exec_date Time.zone.now + 1.day
      archived false
      data({creationDate: Time.now,
            problemDescription: 'Problem description',
            callBack: true,
            contractNumber: 111})
    end

    trait :order_support_request_for_ordering do
      ext_code 'support_ext_code'
      bp_id 'bp_id'
      bp_state 'bp_state'
      state 1
      done_at Time.zone.now
      estimated_exec_date Time.zone.now + 1.day
      archived false
      data({creationDate: Time.now - 1.day,
            problemDescription: 'Other problem description',
            callBack: false,
            contractNumber: 222})
    end

    data({})
  end
end
