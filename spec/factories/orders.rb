FactoryGirl.define do
  factory :order do |order|
    trait :order_vacation_request do
      order.sequence(:order_type) do
        FactoryGirl.create(:order_type, :vacation_request)
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

    data({})
  end
end
