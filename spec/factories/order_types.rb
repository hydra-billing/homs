FactoryBot.define do
  factory :order_type do
    initialize_with do
      new(file: ({
        order_type: {
          code: 'Without custom fields',
          name: 'Empty order type',
          print_form_code: 'print_form_code',
          fields: {}
        }
      }.to_yaml)
         )
    end

    trait :active do
      active true
    end

    trait :vacation_request do
      active true
      code 'Vacation request'
      fields(vacationLeaveDate: {
               type: 'datetime',
               label: 'Leave date',
               required: true,
               multiple: false,
               visible:  true,
               editable: true
             },
             vacationBackDate: {
               type: 'datetime',
               label: 'Vacation end date',
               required: true,
               multiple: false,
               visible:  true,
               editable: true
             },
             employee: {
               type: 'string',
               label: 'Employee',
               required: true,
               multiple: false,
               visible:  true,
               editable: true
             },
             approver: {
               type: 'string',
               label: 'Approver',
               required: true,
               multiple: false,
               visible:  true,
               editable: true
             })
    end

    trait :support_request do
      active true
      code 'Support Request'
      print_form_code 'print_form_code'
      fields(
        creationDate: {
          type: 'datetime',
          label: 'Creation date',
          description: 'Creation date'},
        problemDescription: {
          type: 'string',
          label: 'Problem description',
          description: 'Problem description'},
        callBack: {
          type: 'boolean',
          label: 'Callback',
          description: 'Callback'},
        contractNumber: {
          type: 'number',
          label: 'Contract number',
          description: 'Contract number'})
    end
  end
end
